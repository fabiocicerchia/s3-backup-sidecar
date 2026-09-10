# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.2.1...v1.2.2) (2026-09-10)


### Bug Fixes

* **publish:** sign the images this workflow pushes ([#60](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/60)) ([a850135](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/a850135e2ca2784ebbaf687984fbb7d5e449a3c5))
* **release:** grant id-token on the job that calls the signing workflow ([#61](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/61)) ([9befc66](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/9befc664416ce6b0b284be3cc45a78ad8ffafc23))
* **release:** grant id-token to the job that calls publish ([#63](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/63)) ([3693aa1](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/3693aa127148432f926b1bfa794e51f0ec6e3d34))
* **release:** hand the Docker Hub secrets to the called workflow ([#57](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/57)) ([964eaf5](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/964eaf50ba6a7cc43d1462c2ccccb4a052c01d46))

## [1.2.1](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.2.0...v1.2.1) (2026-09-09)


### Bug Fixes

* honour RUN_ONCE, and open the repository at startup ([#53](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/53)) ([d96ac43](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/d96ac434cbdc0bb5737706410e127e553c7c2573))

## [1.2.0](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.1.2...v1.2.0) (2026-09-08)


### Features

* add the eight-verb repo contract ([#49](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/49)) ([1a41f9b](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/1a41f9bb67e87cded37a57dbf55c8a3dad417746))


### Bug Fixes

* point install docs at an image tag that exists ([#52](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/52)) ([afd7ad2](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/afd7ad2547a2e02699e83eb2011c0043c89b5652))

## [1.1.2](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.1.1...v1.1.2) (2026-09-04)

### Bug Fixes

- **ci:** pin the editorconfig-checker binary version ([#40](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/40)) ([28ffe67](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/28ffe673f22b4204a33a4b98829ac1b6fee45451))

## [1.1.1](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.1.0...v1.1.1) (2026-08-29)

### Bug Fixes

- unblock quality and clear the Scorecard pinned-dependencies finding ([#34](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/34)) ([8bb1502](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/8bb150228690caf9ef3a534044a05a8660b45bc0))

## [1.1.0](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.0.2...v1.1.0) (2026-08-25)

### Features

- **docs:** build the docs site in Actions and drop Read the Docs ([#32](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/32)) ([14f8ed6](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/14f8ed6d3b749578a8acb3cf9c997b8e1aeb8e76))

## [1.0.2](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.0.1...v1.0.2) (2026-08-13)

### Bug Fixes

- security and code-quality findings ([#21](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/21)) ([23b7511](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/23b7511629b00b91573c4806ba1c01a7cc00a1de))

## [1.0.1](https://github.com/fabiocicerchia/s3-backup-sidecar/compare/v1.0.0...v1.0.1) (2026-08-06)

### Bug Fixes

- publish the image from the release job so it actually runs ([c190f01](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/c190f01c4f336f322ad89ec6d92087b76c387b07))

## 1.0.0 (2026-08-06)

### Features

- **chart:** add Helm chart ([cd0abcd](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/cd0abcd44468ce7dae5d1590bd8fd187d1935cf8))

### Bug Fixes

- **ci:** stop security workflows failing on private repos ([#9](https://github.com/fabiocicerchia/s3-backup-sidecar/issues/9)) ([6e01589](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/6e015890b76b5b6b399b945396f71401c5ca84fe))
- **docker:** set pipefail before RUN steps that pipe curl into tar ([7e5514c](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/7e5514cde3932d83e049c59d91cb4d6be33e5d92))
- **pre-commit:** stop check-yaml failing on Helm templates and multi-doc manifests ([a829bd1](https://github.com/fabiocicerchia/s3-backup-sidecar/commit/a829bd1e9940527efb62034a36a3052ccbe26ada))

## [Unreleased]

### Added

- restic sidecar with cron built in and env-only configuration: scheduled,
  encrypted, deduplicated backups with a retention policy, `once` and
  `restore` modes, optional `--read-data-subset` verification and heartbeat.

Not yet released.
