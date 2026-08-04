# s3-backup-sidecar

A **restic**-based backup sidecar with cron built in and 100% env-driven
config. Mount your data volume, set four env vars, get scheduled, encrypted,
deduplicated, retention-managed backups to S3 (or anything restic/rclone
speaks). `rclone` is included for non-restic sync jobs and exotic remotes.

Everyone reinvents this container; this one is tested with a real
backup-and-restore round-trip against MinIO.

## Usage

Sidecar with schedule:

```yaml
containers:
  - name: app
    volumeMounts: [{ name: data, mountPath: /data }]
  - name: backup
    image: fabiocicerchia/s3-backup-sidecar
    env:
      - { name: RESTIC_REPOSITORY, value: "s3:s3.amazonaws.com/my-bucket/my-app" }
      - { name: BACKUP_SCHEDULE,   value: "0 3 * * *" }
      - { name: VERIFY,            value: "true" }
    envFrom: [{ secretRef: { name: backup-credentials } }]  # RESTIC_PASSWORD, AWS keys
    volumeMounts: [{ name: data, mountPath: /data, readOnly: true }]
```

One-shot (Kubernetes CronJob / CI): `args: ["once"]`.
Disaster recovery: `args: ["restore"]` with `RESTORE_TARGET=/data`.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `RESTIC_REPOSITORY` | *required* | restic repo URL |
| `RESTIC_PASSWORD(_FILE)` | *required* | repo encryption key |
| `BACKUP_SCHEDULE` | `0 3 * * *` | cron schedule |
| `BACKUP_PATHS` | `/data` | space-separated paths |
| `RETENTION_ARGS` | `--keep-daily 7 --keep-weekly 4 --keep-monthly 6` | forget policy |
| `VERIFY` | `false` | `restic check --read-data-subset=5%` after each run |
| `PRE_COMMAND` | – | e.g. `pg_dump ... > /data/dump.sql` |
| `HEARTBEAT_URL` | – | pinged on success (healthchecks.io) |

## Development

`make build` / `make lint` / `make test` — the test spins up MinIO and does a
full backup → restore → content-verify round-trip.

## License

Apache-2.0 — see [LICENSE](LICENSE). The image redistributes restic
(BSD-2-Clause), rclone, supercronic and tini (MIT); see [NOTICE](NOTICE).
