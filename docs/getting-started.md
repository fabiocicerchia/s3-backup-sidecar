# Getting Started

## Prerequisites

Docker, and somewhere restic can write: an S3 bucket, or MinIO locally. Four
variables are the whole configuration.

## Try it against MinIO first

Do not point a new backup configuration at a real bucket to find out whether it
works. Run it locally, then restore, then move it:

```sh
docker network create bk
docker run -d --rm --name minio --network bk \
  -e MINIO_ROOT_USER=test -e MINIO_ROOT_PASSWORD=testtest123 \
  minio/minio server /data
```

Back something up:

```sh
mkdir -p data && echo "precious" > data/file.txt

docker run --rm --network bk -v "$PWD/data:/data:ro" \
  -e RESTIC_REPOSITORY=s3:http://minio:9000/backups \
  -e RESTIC_PASSWORD=secret \
  -e AWS_ACCESS_KEY_ID=test -e AWS_SECRET_ACCESS_KEY=testtest123 \
  fabiocicerchia/s3-backup-sidecar once
```

The repository is created on the first run — there is no separate `init` step.

Then restore it, which is the half that matters:

```sh
docker run --rm --network bk -v "$PWD/restored:/restore" \
  -e RESTIC_REPOSITORY=s3:http://minio:9000/backups \
  -e RESTIC_PASSWORD=secret \
  -e AWS_ACCESS_KEY_ID=test -e AWS_SECRET_ACCESS_KEY=testtest123 \
  -e RESTORE_TARGET=/restore \
  fabiocicerchia/s3-backup-sidecar restore

cat restored/data/file.txt      # precious
```

## The three modes

| Argument | What it does | Use it for |
|---|---|---|
| *(none)* | Runs `backup.sh` on `BACKUP_SCHEDULE` via supercronic | A sidecar container |
| `once` | One backup, then exit 0 | A Kubernetes `CronJob`, or CI |
| `restore` | `restic restore latest` into `RESTORE_TARGET` | Disaster recovery |

Anything else is `exec`d, so `docker run ... restic snapshots` works for
inspection.

## As a sidecar

```yaml
containers:
  - name: app
    volumeMounts:
      - { name: data, mountPath: /data }
  - name: backup
    image: fabiocicerchia/s3-backup-sidecar
    env:
      - { name: RESTIC_REPOSITORY, value: "s3:s3.amazonaws.com/my-bucket/my-app" }
      - { name: BACKUP_SCHEDULE,   value: "0 3 * * *" }
      - { name: VERIFY,            value: "true" }
    envFrom:
      - secretRef: { name: backup-credentials }   # RESTIC_PASSWORD, AWS keys
    volumeMounts:
      - { name: data, mountPath: /data, readOnly: true }
```

`readOnly: true` on the backup side is deliberate: restic only reads the
source, and a backup process with write access to the data it protects is a
failure mode you get nothing for.

The container runs as uid 10001, so the mount has to be readable by it —
`fsGroup` in the pod's `securityContext` is the usual answer.

## Back up a database, not its files

Copying a live database's data directory produces a file set that may not
restore. Dump it first:

```yaml
    env:
      - name: PRE_COMMAND
        value: "pg_dump -h localhost -U app app > /dump/app.sql"
      - { name: BACKUP_PATHS, value: "/dump" }
```

`PRE_COMMAND` runs before the snapshot and its failure aborts the run — so a
failed dump does not produce a snapshot of yesterday's dump followed by a prune
that discards the day before.

## Know when it stops working

A backup system that fails silently is worse than none, because it is trusted.
Two things to turn on:

```yaml
      - { name: VERIFY,        value: "true" }
      - { name: HEARTBEAT_URL, value: "https://hc-ping.com/<uuid>" }
```

`VERIFY` runs `restic check --read-data-subset=5%` after retention, which
actually reads blobs back rather than trusting the index. It costs egress, so
it is off by default; turn it on anyway unless the bill says otherwise.

`HEARTBEAT_URL` is pinged only after everything else succeeded, so an alert
fires when a run fails *or* never starts. Its own failure is logged and does
not fail the backup.

## Retention

```yaml
      - { name: RETENTION_ARGS, value: "--keep-daily 7 --keep-weekly 4 --keep-monthly 6" }
```

That is the default. `restic forget --prune` runs after each successful backup,
never before — retention is only ever applied once a newer snapshot exists.

## Check what is actually in there

```sh
docker run --rm --env-file backup.env fabiocicerchia/s3-backup-sidecar \
  restic snapshots
```

Worth doing on a schedule you keep to, not just after an incident.

## Clean up the local test

```sh
docker rm -f minio && docker network rm bk && rm -rf data restored
```

## Development

```sh
make build     # docker build
make lint      # hadolint + shellcheck on entrypoint.sh and backup.sh
make test      # backup -> restore -> content verify, against MinIO
make release   # multi-arch buildx push
```
