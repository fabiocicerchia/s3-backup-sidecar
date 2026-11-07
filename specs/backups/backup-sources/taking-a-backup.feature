@domain:backups @area:backup-sources @from:s3-backup-sidecar/backup
Feature: Taking a backup
  Lets an operator get a tagged, encrypted snapshot of the chosen paths on every run without a separate setup step, so a fresh deployment starts protecting data immediately.

  Background:
    Given Given the backup repository location and password are configured

  @id:backups.backup-sources.001 @rule:backups.sources.default-data-path @verified @source:backup.sh#BACKUP_PATHS @test:test.sh#backup/restore round-trip
  Scenario Outline: A run backs up /data unless other paths are chosen
    Given <paths setting>
    When the sidecar runs a backup
    Then a new snapshot exists containing <backed up paths>
    And the log shows "backup: starting (<backed up paths>)"

    Examples:
      | paths setting                    | backed up paths |
      | no backup paths are configured   | /data           |
      | BACKUP_PATHS is "/tmp/data"      | /tmp/data       |
      | BACKUP_PATHS is "/dump /etc/app" | /dump /etc/app  |

  @id:backups.backup-sources.002 @rule:backups.repository.created-on-first-use @verified @source:backup.sh#restic cat config @test:test.sh#a fresh named volume is not writable by uid 10001 @questionable
  Scenario: The repository is created on the first run when it does not exist yet
    Given the configured repository location is empty
    When the sidecar runs a backup
    Then the log shows "backup: initializing repository"
    And the repository is created and the first snapshot is stored in it

  @id:backups.backup-sources.003 @rule:backups.tags.snapshot-tagged @inferred @source:backup.sh#BACKUP_TAGS
  Scenario Outline: Every snapshot carries the configured tags, sidecar by default
    Given <tag setting>
    When the sidecar runs a backup
    Then the new snapshot is tagged <tags>

    Examples:
      | tag setting                   | tags            |
      | no backup tags are configured | sidecar         |
      | BACKUP_TAGS is "app,nightly"  | app and nightly |

  @id:backups.backup-sources.004 @rule:backups.pre-command.runs-before-snapshot @inferred @source:backup.sh#PRE_COMMAND
  Scenario: The pre-backup command finishes before the snapshot is taken
    Given PRE_COMMAND is "pg_dump -h localhost -U app app > /dump/app.sql"
    And BACKUP_PATHS is "/dump"
    When the sidecar runs a backup
    Then the log shows "backup: running pre-command" before "backup: starting (/dump)"
    And the new snapshot contains the freshly written /dump/app.sql

  @id:backups.backup-sources.005 @rule:backups.pre-command.failure-aborts-run @inferred @source:backup.sh#PRE_COMMAND
  Scenario: A failed pre-backup command stops the run before any snapshot or pruning
    Given the latest snapshot is from yesterday
    And PRE_COMMAND exits non-zero
    When the sidecar runs a backup
    Then the run exits non-zero
    And no new snapshot is taken
    And yesterday's snapshot and all older ones are still kept
