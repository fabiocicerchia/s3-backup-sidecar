@domain:scheduling @area:cron-schedule @from:s3-backup-sidecar/entrypoint
Feature: Running backups on a schedule
  Lets an operator run the container as a long-lived sidecar that takes backups on a cron expression set purely through the environment.

  Background:
    Given the container is started without a mode argument and RUN_ONCE is not "true"

  @id:scheduling.cron-schedule.001 @rule:scheduling.cron.schedule-from-env-with-daily-default @inferred @source:entrypoint.sh#cron
  Scenario Outline: Backups are scheduled on BACKUP_SCHEDULE, or daily at 03:00 when it is unset
    Given RESTIC_REPOSITORY points at a repository the container can open
    And BACKUP_SCHEDULE is <schedule_setting>
    When the operator starts the container
    Then the log shows "s3-backup-sidecar: scheduling backups: <effective_schedule>"
    And the container keeps running and takes a backup at every match of <effective_schedule>

    Examples:
      | schedule_setting | effective_schedule |
      | unset            | 0 3 * * *          |
      | "*/15 * * * *"   | */15 * * * *       |
      | "30 1 * * 0"     | 30 1 * * 0         |

  @id:scheduling.cron-schedule.002 @rule:scheduling.cron.repository-required @inferred @source:entrypoint.sh#cron
  Scenario: Scheduled mode refuses to start without a repository
    Given RESTIC_REPOSITORY is not set
    When the operator starts the container
    Then the container exits with a non-zero status
    And the error output reads "RESTIC_REPOSITORY is required"
    And no backups are scheduled
