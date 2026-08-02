#!/usr/bin/env sh
# Integration test: full backup + restore round-trip against MinIO.
set -eu
IMAGE="${1:?usage: test.sh <image:tag>}"
docker network create s3bk-test >/dev/null
docker run -d --rm --name s3bk-minio --network s3bk-test \
  -e MINIO_ROOT_USER=test -e MINIO_ROOT_PASSWORD=testtest123 \
  minio/minio server /data >/dev/null
sleep 3
docker run --rm --network s3bk-test --entrypoint sh \
  -e AWS_ACCESS_KEY_ID=test -e AWS_SECRET_ACCESS_KEY=testtest123 \
  -e RESTIC_REPOSITORY=s3:http://s3bk-minio:9000/backups \
  -e RESTIC_PASSWORD=secret -e VERIFY=true -e RESTORE_TARGET=/tmp/restore \
  "$IMAGE" -c '
    set -e
    mkdir -p /tmp/data && echo "precious" > /tmp/data/file.txt
    BACKUP_PATHS=/tmp/data backup.sh
    entrypoint.sh restore
    grep -q precious /tmp/restore/tmp/data/file.txt
    echo ROUNDTRIP-OK
  ' || { docker rm -f s3bk-minio >/dev/null; docker network rm s3bk-test >/dev/null; echo FAIL >&2; exit 1; }
docker rm -f s3bk-minio >/dev/null
docker network rm s3bk-test >/dev/null
echo PASS
