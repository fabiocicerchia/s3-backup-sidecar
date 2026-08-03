# Architecture

Three static binaries and two shell scripts. The scripts are short on purpose:
a backup you cannot read in full is a backup you are trusting rather than
running.

```
entrypoint.sh  ── cron    ──► supercronic ──► backup.sh, on BACKUP_SCHEDULE
               ── once    ──► backup.sh, once, then exit      (CronJob / CI)
               ── restore ──► restic restore latest --target $RESTORE_TARGET
               ── *       ──► exec "$@"                        (debugging)

backup.sh: init-if-needed ─► PRE_COMMAND ─► backup ─► forget --prune
                                          └─► check ─► heartbeat
```

## Why supercronic and not crond

`crond` writes to syslog, needs a running syslog daemon to be observable, and
does not propagate a job's exit status to anything a container orchestrator can
see. Supercronic logs to stdout in JSON, runs in the foreground as PID 1's
child, and is built for exactly this.

The crontab is generated at start from `BACKUP_SCHEDULE` — a single line — so
there is no crontab file to mount and no second place for the schedule to live.

## Why the repository is initialised lazily

```sh
restic cat config >/dev/null 2>&1 || restic init
```

`restic init` on an existing repository is an error, and a separate "have you
initialised it yet" step is one more thing to get wrong at 3am. Probing for the
config object makes the first run and the thousandth run the same command.

The cost is that a *misconfigured* repository URL creates a new empty
repository rather than failing. That is the trade, and it is why the restore
path is the thing the test suite exercises.

## The order in `backup.sh` is the design

**`PRE_COMMAND` before the backup, not around it.** A `pg_dump` into the data
directory has to complete before the snapshot is taken. If it fails, `set -e`
stops the run — backing up a half-written dump and then pruning old snapshots
against it is how a backup system destroys the thing it was protecting.

**`forget --prune` after the backup, never before.** Retention is applied only
once the new snapshot exists. A prune that runs first can leave a window with
no valid snapshot at all.

**`check` after retention.** `--read-data-subset=5%` actually reads blobs from
the remote rather than just verifying the index, so it catches a repository
that lists correctly and cannot be restored. Five percent per run, with a daily
schedule, covers the whole repository over a normal retention window without
paying full egress every night. It is off by default because that egress is
real money on S3.

**The heartbeat is last, and its failure is not fatal.** The heartbeat says
"the backup succeeded". Pinging it before the verification would make it say
"the backup started". And a monitoring endpoint being unreachable is not a
reason to mark a successful backup as failed — it is logged and ignored.

## Everything is env vars, including the credentials

restic reads `RESTIC_REPOSITORY`, `RESTIC_PASSWORD`/`RESTIC_PASSWORD_FILE` and
the AWS variables from the environment itself; the scripts do not parse or
forward them. That is why the sidecar has no config file: there is nothing left
to put in one.

It also means `envFrom: secretRef` works with no glue, and that IRSA or an
instance profile works by simply not setting the AWS variables.

`RESTIC_PASSWORD_FILE` is the better of the two. A repository password in the
environment is visible to anything that can read the process environment; a
file can come from a mounted Secret.

## Non-root, and what that means for the mount

The image runs as uid 10001. The data mount must be readable by that uid —
mount it `readOnly: true` in the sidecar, which is both safer and what
`fsGroup` usually makes work without further thought.

restic itself does not need to write to the source, only to read it. A backup
sidecar with write access to the data it is backing up is a needless failure
mode.

## `rclone` is in the image but not in the scripts

It is there for the cases restic does not cover — a plain sync to a remote that
speaks something exotic, or a copy of the restic repository itself to a second
provider. Nothing calls it automatically. Use the `exec "$@"` fallthrough mode.

## Changing it

The invariant to preserve is the ordering above. If you add a step, decide
which side of `forget --prune` it belongs on, and make sure a failure in it
stops the run rather than being swallowed.

`make test` is the check that matters: it runs a real backup and a real restore
against MinIO and compares the file contents. A backup tool that is only tested
on the write path is untested.
