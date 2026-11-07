@domain:retention-recovery @area:restore @from:s3-backup-sidecar/entrypoint
Feature: Restoring the latest snapshot
  Lets an operator recover data by restoring the most recent snapshot into a directory they choose.

  Background:
    Given RESTIC_REPOSITORY and RESTIC_PASSWORD are set for a repository holding snapshots

  @id:retention-recovery.restore.001 @rule:recovery.restore.latest-into-target @verified @source:entrypoint.sh#restore @test:test.sh#backup/restore round-trip
  Scenario: Restore writes the latest snapshot into RESTORE_TARGET under the original paths
    Given the latest snapshot contains /data/file.txt with content "precious"
    And RESTORE_TARGET is "/tmp/restore"
    When the operator starts the container with argument restore
    Then /tmp/restore/data/file.txt exists with content "precious"
    And the container exits with status 0

  @id:retention-recovery.restore.002 @rule:recovery.restore.target-required @inferred @source:entrypoint.sh#restore
  Scenario: Restore is refused when no target directory is given
    Given RESTORE_TARGET is not set
    When the operator starts the container with argument restore
    Then the container exits with a non-zero status
    And the error output shows "RESTORE_TARGET is required for restore"
    And nothing is restored
