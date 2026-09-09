# s3-backup-sidecar

[![CI](https://github.com/fabiocicerchia/s3-backup-sidecar/actions/workflows/ci.yml/badge.svg)](https://github.com/fabiocicerchia/s3-backup-sidecar/actions/workflows/ci.yml)
[![Code Quality](https://github.com/fabiocicerchia/s3-backup-sidecar/actions/workflows/code-quality.yml/badge.svg)](https://github.com/fabiocicerchia/s3-backup-sidecar/actions/workflows/code-quality.yml)
[![Security](https://github.com/fabiocicerchia/s3-backup-sidecar/actions/workflows/security.yml/badge.svg)](https://github.com/fabiocicerchia/s3-backup-sidecar/actions/workflows/security.yml)
[![License](https://img.shields.io/badge/license-Apache_2.0-blue.svg)](LICENSE)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/fabiocicerchia/s3-backup-sidecar/badge)](https://securityscorecards.dev/viewer/?uri=github.com/fabiocicerchia/s3-backup-sidecar)
[![CI carbon](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/fabiocicerchia/s3-backup-sidecar/gh-pages/badge.json)](.github/workflows/carbon-badge.yml)

A **restic**-based backup sidecar with cron built in and 100% env-driven
config. Mount your data volume, set four env vars, get scheduled, encrypted,
deduplicated, retention-managed backups to S3 (or anything restic/rclone
speaks). `rclone` is included for non-restic sync jobs and exotic remotes.

Everyone reinvents this container; this one is tested with a real
backup-and-restore round-trip against MinIO.

## Install

```sh
make build                       # builds the image locally, tagged from version.txt
docker pull ghcr.io/fabiocicerchia/s3-backup-sidecar:latest      # or pin a release: :1.1.2
```

## Usage

Sidecar with schedule:

```yaml
containers:
  - name: app
    volumeMounts: [{ name: data, mountPath: /data }]
  - name: backup
    image: ghcr.io/fabiocicerchia/s3-backup-sidecar
    env:
      - { name: RESTIC_REPOSITORY, value: "s3:s3.amazonaws.com/my-bucket/my-app" }
      - { name: BACKUP_SCHEDULE,   value: "0 3 * * *" }
      - { name: VERIFY,            value: "true" }
    envFrom: [{ secretRef: { name: backup-credentials } }]  # RESTIC_PASSWORD, AWS keys
    volumeMounts: [{ name: data, mountPath: /data, readOnly: true }]
```

One-shot (Kubernetes CronJob / CI): `args: ["once"]`, or `RUN_ONCE=true` where
passing an argument is awkward. Disaster recovery: `args: ["restore"]` with
`RESTORE_TARGET=/data`.

The repository has to be reachable **and writable** by uid 10001. In cron mode
that is checked at startup rather than on the first tick: a root-owned named
volume otherwise fails every scheduled run while the container sits there
looking healthy.

## Configuration

| Variable                 | Default                                           | Purpose                                             |
| ------------------------ | ------------------------------------------------- | --------------------------------------------------- |
| `RESTIC_REPOSITORY`      | *required*                                        | restic repo URL                                     |
| `RESTIC_PASSWORD(_FILE)` | *required*                                        | repo encryption key                                 |
| `BACKUP_SCHEDULE`        | `0 3 * * *`                                       | cron schedule                                       |
| `RUN_ONCE`               | `false`                                           | `true` = one backup, then exit (same as `once`)     |
| `BACKUP_PATHS`           | `/data`                                           | space-separated paths                               |
| `RETENTION_ARGS`         | `--keep-daily 7 --keep-weekly 4 --keep-monthly 6` | forget policy                                       |
| `VERIFY`                 | `false`                                           | `restic check --read-data-subset=5%` after each run |
| `PRE_COMMAND`            | –                                                 | e.g. `pg_dump ... > /data/dump.sql`                 |
| `HEARTBEAT_URL`          | –                                                 | pinged on success (healthchecks.io)                 |

## Development

`make test` spins up MinIO and does a full backup → restore → content-verify
round-trip.

### Make targets

`make help` lists them. Every repository in this estate exposes the same eight
verbs, so you do not have to read a Makefile to find out how to build or test it
(FC-GEN-057).

| Verb      | What it does here                                        |
| --------- | -------------------------------------------------------- |
| `setup`   | Install the pre-commit hook                              |
| `install` | `docker pull` the published image                        |
| `build`   | Build the image locally                                  |
| `test`    | Build, then run the smoke tests                          |
| `lint`    | `pre-commit run --all-files` — the whole gate            |
| `run`     | Run the sidecar from the image; `ARGS` are its arguments |
| `format`  | Rewrite what the gate can fix: whitespace, endings, EOF  |
| `analyze` | `trivy fs` — the same scan CI runs                       |

`make push` and `make release` publish the image; the release workflow is what
normally runs them.

## Documentation

Full docs live in [`docs/`](docs/). Runnable examples live in [`examples/`](examples/).

## License

Apache-2.0 — see [LICENSE](LICENSE). The image redistributes restic
(BSD-2-Clause), rclone, supercronic and tini (MIT); see [NOTICE](NOTICE).
