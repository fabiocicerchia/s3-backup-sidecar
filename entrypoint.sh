#!/bin/sh
# Modes:
#   (default)          run backup.sh on BACKUP_SCHEDULE via supercronic
#   entrypoint once    run a single backup and exit (Job-friendly)
#   entrypoint restore run `restic restore latest` into RESTORE_TARGET
set -eu

case "${1:-cron}" in
  once)    exec backup.sh ;;
  restore)
    : "${RESTORE_TARGET:?RESTORE_TARGET is required for restore}"
    exec restic restore latest --target "$RESTORE_TARGET" ;;
  cron)
    SCHEDULE="${BACKUP_SCHEDULE:-0 3 * * *}"
    echo "s3-backup-sidecar: scheduling backups: $SCHEDULE"
    printf '%s backup.sh\n' "$SCHEDULE" > /tmp/crontab
    exec supercronic -json /tmp/crontab ;;
  *) exec "$@" ;;
esac
