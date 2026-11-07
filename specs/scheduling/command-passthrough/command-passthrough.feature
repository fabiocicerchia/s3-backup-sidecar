@domain:scheduling @area:command-passthrough @from:s3-backup-sidecar/entrypoint
Feature: Running other commands in the container
  Lets operators use the image's bundled tools directly, for inspection or one-off maintenance, without overriding the entrypoint.

  @id:scheduling.command-passthrough.001 @rule:scheduling.passthrough.unknown-argument-runs-as-command @inferred @source:entrypoint.sh#cron
  Scenario: Any argument other than a mode runs as a command
    Given RESTIC_REPOSITORY and RESTIC_PASSWORD are set for a repository holding snapshots
    When the operator starts the container with arguments "restic snapshots"
    Then the repository's snapshot list is printed
    And the container exits with restic's exit status
    And no backup is taken and none is scheduled
