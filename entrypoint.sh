#!/bin/sh
# Modes:
#   (default)          run backup.sh on BACKUP_SCHEDULE via supercronic
#   entrypoint once    run a single backup and exit (Job-friendly)
#   entrypoint restore run `restic restore latest` into RESTORE_TARGET
#
# RUN_ONCE=true selects `once` without an argument. Everything else about this
# image is configured through the environment, so a caller that sets only env
# vars — `docker run … s3-backup-sidecar` in a test, a CI step — reasonably
# expects that to work; before it did, the container scheduled a backup for
# 03:00 and ran until it was killed, having backed nothing up.
set -eu

mode="${1:-cron}"
if [ "$mode" = "cron" ] && [ "${RUN_ONCE:-false}" = "true" ]; then
  mode=once
fi

case "$mode" in
  once)    exec backup.sh ;;
  restore)
    : "${RESTORE_TARGET:?RESTORE_TARGET is required for restore}"
    exec restic restore latest --target "$RESTORE_TARGET" ;;
  cron)
    : "${RESTIC_REPOSITORY:?RESTIC_REPOSITORY is required}"
    SCHEDULE="${BACKUP_SCHEDULE:-0 3 * * *}"
    # Reach the repository now, not at 03:00. A named volume is created
    # root-owned and this image runs as uid 10001, so `restic init` fails with
    # "permission denied" on every tick — into a log nobody reads, while the
    # container stays up and looks healthy. Failing here instead makes it a
    # crash loop, which is what a container that can never do its job is.
    if ! restic cat config >/dev/null 2>&1 && ! restic init; then
      echo "s3-backup-sidecar: cannot open or create $RESTIC_REPOSITORY — not scheduling backups that would all fail" >&2
      echo "s3-backup-sidecar: for a local path, the volume must be writable by uid 10001: a named volume is created" >&2
      echo "s3-backup-sidecar: root-owned (chown it, or docker run --user), and in Kubernetes fsGroup: 10001 does it." >&2
      exit 1
    fi
    echo "s3-backup-sidecar: scheduling backups: $SCHEDULE"
    printf '%s backup.sh\n' "$SCHEDULE" > /tmp/crontab
    exec supercronic -json /tmp/crontab ;;
  *) exec "$@" ;;
esac
