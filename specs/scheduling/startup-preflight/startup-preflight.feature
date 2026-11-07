@domain:scheduling @area:startup-preflight @from:s3-backup-sidecar/entrypoint
Feature: Checking the repository before scheduling backups
  Protects operators from a healthy-looking sidecar whose every scheduled backup would fail, by opening or creating the repository at startup.

  Background:
    Given the container is started in scheduled mode
    And RESTIC_PASSWORD is "example-passphrase"

  @id:scheduling.startup-preflight.001 @rule:scheduling.preflight.repository-created-on-first-use @inferred @source:entrypoint.sh#cron
  Scenario: A repository that does not exist yet is created at startup
    Given RESTIC_REPOSITORY is "s3:https://s3.example.com/acme-backups" and holds no repository yet
    And the credentials allow writing to it
    When the operator starts the container
    Then a new encrypted repository exists at s3:https://s3.example.com/acme-backups
    And the log shows "s3-backup-sidecar: scheduling backups: 0 3 * * *"
    And the container keeps running

  @id:scheduling.startup-preflight.002 @rule:scheduling.preflight.unusable-repository-refused @verified @source:entrypoint.sh#cron @test:test.sh#cron mode scheduled backups against an unusable repository
  Scenario Outline: The container refuses to schedule backups against a repository it can neither open nor create
    Given RESTIC_REPOSITORY is "<repository>", <why unusable>
    When the operator starts the container
    Then the container exits with status 1
    And the error output reads "s3-backup-sidecar: cannot open or create <repository> — not scheduling backups that would all fail"
    And the error output advises that a local volume must be writable by uid 10001, via chown, docker run --user, or Kubernetes fsGroup: 10001
    And no backups are scheduled

    Examples:
      | repository           | why unusable                                  |
      | /nonexistent/nowhere | a path uid 10001 cannot create                |
      | /backups/repo        | on a root-owned volume uid 10001 cannot write |
