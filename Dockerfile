# s3-backup-sidecar — restic (or rclone) backup sidecar with cron built in,
# configured entirely via env vars. The sidecar everyone reinvents.
ARG RESTIC_VERSION=0.18.0
ARG RCLONE_VERSION=1.70.2
ARG SUPERCRONIC_VERSION=0.2.33

FROM alpine:3.22 AS fetch
ARG RESTIC_VERSION
ARG RCLONE_VERSION
ARG SUPERCRONIC_VERSION
ARG TARGETARCH=amd64
RUN apk add --no-cache curl ca-certificates bzip2 unzip
RUN curl -fsSL "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${TARGETARCH}.bz2" \
      | bzcat > /restic && chmod 0755 /restic
RUN curl -fsSLo /rclone.zip "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-${TARGETARCH}.zip" \
 && unzip -j /rclone.zip '*/rclone' -d / && chmod 0755 /rclone
RUN curl -fsSLo /supercronic \
      "https://github.com/aptible/supercronic/releases/download/v${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" \
 && chmod 0755 /supercronic

FROM alpine:3.22
LABEL org.opencontainers.image.title="s3-backup-sidecar" \
      org.opencontainers.image.description="restic/rclone backup sidecar with built-in cron, env-driven config" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.source="https://github.com/fabiocicerchia/freelancing"
RUN apk add --no-cache ca-certificates tini tzdata curl \
 && adduser -D -u 10001 backup
COPY --from=fetch /restic /rclone /supercronic /usr/local/bin/
COPY backup.sh entrypoint.sh /usr/local/bin/
USER 10001
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
