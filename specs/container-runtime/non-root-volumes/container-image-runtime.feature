@domain:container-runtime @area:non-root-volumes @from:s3-backup-sidecar/dockerfile
Feature: Running the sidecar container image
  Operators who deploy the sidecar rely on the image to run unprivileged, write to a fresh backup volume, ship working restic and rclone tools, stop cleanly and carry its licence and timezone data.

  Background:
    Given the operator has the s3-backup-sidecar image

  @id:container-runtime.non-root-volumes.001 @rule:container.runtime.runs-as-non-root @inferred @source:Dockerfile#USER 10001
  Scenario: The sidecar runs as an unprivileged user, never as root
    Given no user override is set for the container
    When the operator starts the sidecar
    Then every process in the container runs as uid 10001
    And no process in the container runs as root

  @id:container-runtime.non-root-volumes.002 @rule:container.runtime.fresh-named-volume-writable @inferred @source:Dockerfile#RUN mkdir -p /backups && chown 10001:10001 /backups
  Scenario: A brand-new named volume mounted at /backups can be written to
    Given the operator has created an empty named volume
    And the repository is a local path under /backups
    When the operator runs a one-shot backup with that volume mounted at /backups
    Then the repository is created inside the volume
    And the backup completes and the container exits with status 0

  @id:container-runtime.non-root-volumes.003 @rule:container.tools.restic-rclone-bundled @inferred @source:Dockerfile#COPY --from=fetch /restic /rclone /supercronic /usr/local/bin/
  Scenario Outline: restic and rclone are available inside the image
    Given nothing is installed in the container beyond the image itself
    When the operator starts the container with arguments "<tool>"
    Then the tool prints its version
    And the command exits with status 0

    Examples:
      | tool           |
      | restic version |
      | rclone version |

  @id:container-runtime.non-root-volumes.004 @rule:container.runtime.stops-promptly-on-signal @inferred @source:Dockerfile#ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
  Scenario: Stopping the container ends the sidecar promptly
    Given the sidecar is running on its backup schedule
    When the operator stops the container
    Then the stop signal reaches the scheduler
    And the container exits without waiting for the forced-kill timeout

  @id:container-runtime.non-root-volumes.005 @rule:container.runtime.timezone-honoured @inferred @source:Dockerfile#RUN apk add --no-cache ca-certificates tini tzdata curl
  Scenario: The schedule follows the timezone the operator sets
    Given the operator sets TZ to "Europe/Rome"
    And the backup schedule is "0 3 * * *"
    When the operator starts the sidecar
    Then the backup runs at 03:00 Europe/Rome time, not 03:00 UTC
