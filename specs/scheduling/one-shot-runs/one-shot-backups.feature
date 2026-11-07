@domain:scheduling @area:one-shot-runs @from:s3-backup-sidecar/entrypoint
Feature: Taking a single backup and exiting
  Lets Kubernetes Jobs, CI steps and ad-hoc runs take exactly one backup and exit with its result instead of waiting for a schedule.

  Background:
    Given RESTIC_REPOSITORY and RESTIC_PASSWORD are set for a reachable repository

  @id:scheduling.one-shot-runs.001 @rule:scheduling.one-shot.selected-by-argument-or-run-once @verified @source:entrypoint.sh#once @test:test.sh#RUN_ONCE=true did not take one backup and exit
  Scenario Outline: A single backup runs and the container exits when asked by argument or by RUN_ONCE
    Given the container is started with argument <argument> and RUN_ONCE <run_once>
    When the operator starts the container
    Then one backup is taken immediately
    And the container exits with the backup's exit status
    And no schedule is set up

    Examples:
      | argument | run_once |
      | once     | unset    |
      | none     | "true"   |
      | cron     | "true"   |

  @id:scheduling.one-shot-runs.002 @rule:scheduling.one-shot.run-once-only-literal-true @inferred @source:entrypoint.sh#once @questionable
  Scenario Outline: RUN_ONCE switches to a single backup only when it is exactly "true"
    Given the container is started without a mode argument
    And RUN_ONCE is <run_once>
    When the operator starts the container
    Then the log shows "s3-backup-sidecar: scheduling backups: 0 3 * * *"
    And the container keeps running instead of exiting after one backup

    Examples:
      | run_once |
      | "TRUE"   |
      | "1"      |
      | "yes"    |
      | "false"  |

  @id:scheduling.one-shot-runs.003 @rule:scheduling.one-shot.explicit-mode-overrides-run-once @inferred @source:entrypoint.sh#once
  Scenario: An explicit mode argument wins over RUN_ONCE
    Given RUN_ONCE is "true"
    And RESTORE_TARGET is "/restore"
    When the operator starts the container with argument restore
    Then the latest snapshot is restored into /restore
    And no backup is taken
