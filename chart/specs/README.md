# Specifications of s3-backup-sidecar / chart

What this code does, one atomic Gherkin scenario per behaviour, read from the code by code-atlas.
Tags: `@verified` a test asserts it · `@inferred` read from the code only · `@gap` an entry point no test covers · `@human` written or amended by a person, never rewritten.

## Kubernetes Deployment
Installing and running the sidecar on Kubernetes through the bundled Helm chart.

- **Chart validation**: [Validating the Helm chart before release](kubernetes-deployment/chart-validation/chart-validation.feature) (2)
