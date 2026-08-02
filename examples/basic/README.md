# Basic Example

What it shows: a scheduled backup running against MinIO, and the restore that
proves it worked. The restore is the part worth running.

## Run

```sh
mkdir -p data restored
echo "precious" > data/file.txt

docker compose -f compose.yaml up -d
docker compose -f compose.yaml logs -f backup
```

The schedule is `* * * * *`, so within a minute:

```text
s3-backup-sidecar: scheduling backups: * * * * *
backup: initializing repository
backup: starting (/data)
backup: applying retention (--keep-daily 7 --keep-weekly 4 --keep-monthly 6)
backup: verifying (5% read subset)
backup: done
```

No `restic init` step: the repository is created on the first run, and every
run after that skips it.

## Prove it restores

```sh
docker compose -f compose.yaml --profile restore run --rm restore
cat restored/data/file.txt      # precious
```

Do this before pointing anything at a real bucket. A backup that has never been
restored is a hypothesis.

## Watch retention behave

Change the file and wait for another run:

```sh
echo "precious v2" > data/file.txt
sleep 70
docker compose -f compose.yaml run --rm backup restic snapshots
```

Two snapshots, and `restore` fetches `latest`. `restic forget --prune` runs
after each backup, never before — so there is no moment where retention has
been applied and no new snapshot exists yet.

## Point it at something real

Two changes, both in `compose.yaml`:

```yaml
      RESTIC_REPOSITORY: "s3:s3.eu-west-1.amazonaws.com/my-bucket/my-app"
      # delete AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY if using IRSA or an
      # instance profile — restic reads the ambient credentials itself
```

And move `RESTIC_PASSWORD` out of the file: use `RESTIC_PASSWORD_FILE` with a
mounted secret. Losing that password means losing the repository; leaving it in
a compose file means it is in the repository history.

Consider a real schedule (`0 3 * * *`) and a `HEARTBEAT_URL`, so a run that
stops happening is noticed by something other than a restore attempt.

## Clean up

```sh
docker compose -f compose.yaml down -v
rm -rf data restored
```
