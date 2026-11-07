@domain:observability @area:heartbeat @from:s3-backup-sidecar/backup
Feature: Monitoring backup runs
  Gives operators a dead-man-switch signal and a clear refusal when a run cannot succeed, so a broken backup never looks healthy.

  @id:observability.heartbeat.001 @rule:observability.heartbeat.pinged-after-success @inferred @source:backup.sh#HEARTBEAT_URL
  Scenario Outline: The heartbeat URL is called only after every step of the run succeeded
    Given HEARTBEAT_URL is "https://hc-ping.example.com/0b6e"
    And <run state>
    When the sidecar runs a backup
    Then <heartbeat outcome>

    Examples:
      | run state                      | heartbeat outcome                                                       |
      | backup and retention succeed   | the heartbeat URL receives one GET and the log ends with "backup: done" |
      | the backup step fails          | the heartbeat URL is not called and the run exits non-zero              |
      | no heartbeat URL is configured | no heartbeat is sent and the log ends with "backup: done"               |

  @id:observability.heartbeat.002 @rule:observability.heartbeat.failure-non-fatal @inferred @source:backup.sh#HEARTBEAT_URL
  Scenario: An unreachable heartbeat endpoint does not fail a successful backup
    Given HEARTBEAT_URL is "https://hc-ping.example.com/0b6e"
    And the heartbeat endpoint is unreachable or answers with an error
    When the sidecar runs a backup
    Then the error output shows "backup: heartbeat ping failed (non-fatal)"
    And the log ends with "backup: done"
    And the run exits zero

  @id:observability.heartbeat.003 @rule:observability.failure.repository-required @inferred @source:backup.sh#RESTIC_REPOSITORY
  Scenario: A run without a repository location is refused
    Given RESTIC_REPOSITORY is not set
    When the sidecar runs a backup
    Then the run exits non-zero
    And the error output shows "RESTIC_REPOSITORY is required"
    And nothing is backed up

  @id:observability.heartbeat.004 @rule:security.logging.pre-command-not-echoed @inferred @source:backup.sh#PRE_COMMAND
  Scenario: The run log does not echo the pre-backup command
    Given PRE_COMMAND is "PGPASSWORD=s3cr3t-example pg_dump -h db.example.com app > /dump/app.sql"
    When the sidecar runs a backup
    Then the log shows "backup: running pre-command"
    And the log does not contain "s3cr3t-example"
