#!/usr/bin/env sh
# Integration test: full backup + restore round-trip against MinIO, plus the
# two ways the container is meant to stop on its own.
set -eu
IMAGE="${1:?usage: test.sh <image:tag>}"

cleanup() {
  docker rm -f s3bk-minio >/dev/null 2>&1 || true
  docker network rm s3bk-test >/dev/null 2>&1 || true
}
fail() { echo "FAIL: $1" >&2; cleanup; exit 1; }

# `timeout` where there is one: a mode that is supposed to exit and doesn't
# must fail this test, not hang it for as long as the CI job is allowed to run.
GUARD=""
command -v timeout >/dev/null 2>&1 && GUARD="timeout 180"

docker network create s3bk-test >/dev/null
docker run -d --rm --name s3bk-minio --network s3bk-test \
  -e MINIO_ROOT_USER=test -e MINIO_ROOT_PASSWORD=testtest123 \
  minio/minio server /data >/dev/null
sleep 3

S3_ENV="-e AWS_ACCESS_KEY_ID=test -e AWS_SECRET_ACCESS_KEY=testtest123 \
  -e RESTIC_REPOSITORY=s3:http://s3bk-minio:9000/backups -e RESTIC_PASSWORD=secret"

# shellcheck disable=SC2086  # S3_ENV is a deliberate word-split argument list
docker run --rm --network s3bk-test --entrypoint sh $S3_ENV \
  -e VERIFY=true -e RESTORE_TARGET=/tmp/restore \
  "$IMAGE" -c '
    set -e
    mkdir -p /tmp/data && echo "precious" > /tmp/data/file.txt
    BACKUP_PATHS=/tmp/data backup.sh
    entrypoint.sh restore
    grep -q precious /tmp/restore/tmp/data/file.txt
    echo ROUNDTRIP-OK
  ' || fail "backup/restore round-trip"

# RUN_ONCE has to take one backup and exit. It used to be ignored, so a caller
# that configures the image entirely through env got a container scheduling a
# backup for 03:00 and running until it was killed, having backed nothing up.
# shellcheck disable=SC2086
$GUARD docker run --rm --network s3bk-test $S3_ENV \
  -e RUN_ONCE=true -e BACKUP_PATHS=/etc/hostname "$IMAGE" >/dev/null \
  || fail "RUN_ONCE=true did not take one backup and exit"

# Cron mode opens the repository at startup, so a repository it can never write
# is a crash loop rather than a healthy-looking container failing every tick.
# shellcheck disable=SC2086
if $GUARD docker run --rm -e RESTIC_REPOSITORY=/nonexistent/nowhere \
  -e RESTIC_PASSWORD=secret "$IMAGE" >/dev/null 2>&1; then
  fail "cron mode scheduled backups against an unusable repository"
fi

# A brand-new named volume is the documented sidecar usage, and it used to fail
# on `restic init` with EACCES because Docker creates the volume root-owned.
# The image now carries /backups owned by 10001, which an empty volume inherits.
vol="s3bk-test-vol-$$"
docker volume create "$vol" >/dev/null
# shellcheck disable=SC2086
$GUARD docker run --rm -e RESTIC_REPOSITORY=/backups/probe -e RESTIC_PASSWORD=secret \
  -e BACKUP_PATHS=/etc/hostname -e RUN_ONCE=true -v "$vol:/backups" "$IMAGE" >/dev/null \
  || { docker volume rm -f "$vol" >/dev/null 2>&1; fail "a fresh named volume is not writable by uid 10001"; }
docker volume rm -f "$vol" >/dev/null 2>&1

cleanup
echo PASS
