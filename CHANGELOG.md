# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.0.1...v1.0.2) (2026-08-13)


### Bug Fixes

* security and code-quality findings ([#21](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/21)) ([23b7511](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/23b7511629b00b91573c4806ba1c01a7cc00a1de))

## [1.0.1](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.0.0...v1.0.1) (2026-08-06)


### Bug Fixes

* publish the image from the release job so it actually runs ([c190f01](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/c190f01c4f336f322ad89ec6d92087b76c387b07))

## 1.0.0 (2026-08-06)


### Features

* **chart:** add Helm chart ([cd0abcd](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/cd0abcd44468ce7dae5d1590bd8fd187d1935cf8))


### Bug Fixes

* **ci:** stop security workflows failing on private repos ([#9](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/9)) ([6e01589](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/6e015890b76b5b6b399b945396f71401c5ca84fe))
* **docker:** set pipefail before RUN steps that pipe curl into tar ([7e5514c](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/7e5514cde3932d83e049c59d91cb4d6be33e5d92))
* **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([a829bd1](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/a829bd1e9940527efb62034a36a3052ccbe26ada))

## [Unreleased]

### Added

- restic sidecar with cron built in and env-only configuration: scheduled,
  encrypted, deduplicated backups with a retention policy, `once` and
  `restore` modes, optional `--read-data-subset` verification and heartbeat.

Not yet released.
