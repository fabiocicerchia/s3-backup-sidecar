@domain:retention-recovery @area:retention-policy @from:s3-backup-sidecar/backup
Feature: Pruning and verifying backups
  Keeps the repository to a configurable history and optionally proves the stored data can be read back, without ever pruning against a failed run.

  Background:
    Given Given the backup repository holds earlier snapshots

  @id:retention-recovery.retention-policy.001 @rule:retention.policy.keep-policy-applied-each-run @inferred @source:backup.sh#RETENTION_ARGS
  Scenario Outline: Old snapshots are removed and pruned by the keep policy after each backup
    Given <retention setting>
    When the sidecar runs a backup
    Then the log shows "backup: applying retention (<policy>)"
    And snapshots outside <policy> are removed and their data pruned

    Examples:
      | retention setting                 | policy                                          |
      | no retention policy is configured | --keep-daily 7 --keep-weekly 4 --keep-monthly 6 |
      | RETENTION_ARGS is "--keep-last 3" | --keep-last 3                                   |

  @id:retention-recovery.retention-policy.002 @rule:retention.policy.only-after-successful-backup @inferred @source:backup.sh#restic forget
  Scenario: Retention is never applied when the backup itself fails
    Given the snapshot cannot be written
    When the sidecar runs a backup
    Then the run exits non-zero
    And no snapshots are removed

  @id:retention-recovery.retention-policy.003 @rule:retention.verify.opt-in-read-subset @inferred @source:backup.sh#VERIFY @questionable
  Scenario Outline: Reading back a sample of the data is done only when verification is switched on
    Given VERIFY is <verify>
    When the sidecar runs a backup
    Then <outcome>

    Examples:
      | verify | outcome                                                                                   |
      | "true" | the log shows "backup: verifying (5% read subset)" and 5% of the stored data is read back |
      | unset  | no data is read back                                                                      |
      | "TRUE" | no data is read back                                                                      |
      | "1"    | no data is read back                                                                      |

  @id:retention-recovery.retention-policy.004 @rule:retention.verify.failure-fails-run @inferred @source:backup.sh#restic check
  Scenario: A failed verification fails the run and suppresses the heartbeat
    Given VERIFY is "true"
    And HEARTBEAT_URL is "https://hc-ping.example.com/0b6e"
    And part of the stored data cannot be read back
    When the sidecar runs a backup
    Then the run exits non-zero
    And the heartbeat URL is not called
