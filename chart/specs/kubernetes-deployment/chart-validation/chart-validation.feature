@domain:kubernetes-deployment @area:chart-validation @from:chart/check
Feature: Validating the Helm chart before release
  Lets a chart maintainer confirm, with one command, that the Helm chart lints cleanly and renders a workload with a container image using its default values, so a broken chart never reaches operators.

  Background:
    Given the Helm chart for the backup sidecar with its default values

  @id:chart.kubernetes-deployment.chart-validation.001 @rule:kubernetes-deployment.chart-validation.default-render-passes @inferred @source:chart/check.sh#helm
  Scenario: A chart that lints and renders a container image with default values passes validation
    Given the chart has no lint findings that fail
    And rendering the chart with default values produces a workload that names a container image
    When the chart maintainer runs the chart check
    Then the check prints "OK"
    And the check exits with status 0

  @id:chart.kubernetes-deployment.chart-validation.002 @rule:kubernetes-deployment.chart-validation.broken-chart-fails @inferred @source:chart/check.sh#helm
  Scenario Outline: A chart that fails to lint, fails to render, or renders no container image fails validation
    Given <defect>
    When the chart maintainer runs the chart check
    Then the check exits with a non-zero status
    And the check does not print "OK"

    Examples:
      | defect                                         |
      | the chart has a lint error                     |
      | a template fails to render with default values |
      | the default render contains no container image |
