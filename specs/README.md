# Specifications of s3-backup-sidecar

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## Backups
Taking an encrypted, deduplicated snapshot of the mounted data on every run.

- **Backup sources**: [Taking a backup](backups/backup-sources/taking-a-backup.feature) (5)

## Container image
The packaged image the sidecar ships as and how it behaves at runtime.

- **Non-root user & volumes**: [Running the sidecar container image](container-runtime/non-root-volumes/container-image-runtime.feature) (5)

## Documentation site
How the project's docs and splash page look.

- **Page components**: [Styling the documentation page components](documentation/page-components/docs-page-components.feature) (3)
- **Theme & branding**: [Branding the documentation site](documentation/theme-branding/docs-theme-branding.feature) (3)

## Monitoring
Showing operators whether backups are working.

- **Heartbeat pings**: [Monitoring backup runs](observability/heartbeat/backup-run-monitoring.feature) (4)

## Retention & recovery
Keeping the right snapshots, checking they can be read back, and getting data out again.

- **Restore**: [Restoring the latest snapshot](retention-recovery/restore/restoring-latest-snapshot.feature) (2)
- **Retention policy**: [Pruning and verifying backups](retention-recovery/retention-policy/retention-and-verification.feature) (4)

## Scheduling & run modes
When and how the sidecar runs: on a schedule, once, or as some other command.

- **Command passthrough**: [Running other commands in the container](scheduling/command-passthrough/command-passthrough.feature) (1)
- **Cron schedule**: [Running backups on a schedule](scheduling/cron-schedule/scheduled-backups.feature) (2)
- **One-shot runs**: [Taking a single backup and exiting](scheduling/one-shot-runs/one-shot-backups.feature) (3)
- **Startup preflight**: [Checking the repository before scheduling backups](scheduling/startup-preflight/startup-preflight.feature) (2)
