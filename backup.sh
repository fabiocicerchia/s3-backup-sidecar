#!/bin/sh
# One backup run: init repo if needed, backup BACKUP_PATHS, apply retention,
# optionally verify, optionally ping a heartbeat URL.
#
# Required env:
#   RESTIC_REPOSITORY      e.g. s3:s3.amazonaws.com/my-bucket/my-app
#   RESTIC_PASSWORD        (or RESTIC_PASSWORD_FILE)
#   AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY (or IRSA / instance profile)
# Optional:
#   BACKUP_PATHS           space-separated paths   (default /data)
#   BACKUP_TAGS            comma-separated tags    (default sidecar)
#   RETENTION_ARGS         forget policy           (default --keep-daily 7 --keep-weekly 4 --keep-monthly 6)
#   VERIFY=true            run `restic check --read-data-subset=5%` after backup
#   HEARTBEAT_URL          GET on success (healthchecks.io style)
#   PRE_COMMAND            shell command before backup (e.g. pg_dump)
set -eu

: "${RESTIC_REPOSITORY:?RESTIC_REPOSITORY is required}"

BACKUP_PATHS="${BACKUP_PATHS:-/data}"
BACKUP_TAGS="${BACKUP_TAGS:-sidecar}"
RETENTION_ARGS="${RETENTION_ARGS:---keep-daily 7 --keep-weekly 4 --keep-monthly 6}"

restic cat config >/dev/null 2>&1 || { echo "backup: initializing repository"; restic init; }

if [ -n "${PRE_COMMAND:-}" ]; then
  echo "backup: running pre-command"
  sh -c "$PRE_COMMAND"
fi

echo "backup: starting ($BACKUP_PATHS)"
# shellcheck disable=SC2086
restic backup --tag "$BACKUP_TAGS" $BACKUP_PATHS

echo "backup: applying retention ($RETENTION_ARGS)"
# shellcheck disable=SC2086
restic forget --prune $RETENTION_ARGS

if [ "${VERIFY:-false}" = "true" ]; then
  echo "backup: verifying (5% read subset)"
  restic check --read-data-subset=5%
fi

if [ -n "${HEARTBEAT_URL:-}" ]; then
  curl -fsS -m 10 -o /dev/null "$HEARTBEAT_URL" || echo "backup: heartbeat ping failed (non-fatal)" >&2
fi

echo "backup: done"
