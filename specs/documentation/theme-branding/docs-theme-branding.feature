@domain:documentation @area:theme-branding @from:docs/stylesheets
Feature: Branding the documentation site
  Gives readers of the docs and the splash page one consistent, legible look, so the project reads as a single product.

  Background:
    Given the documentation site is published with the rendered docs under /docs/ and the splash page at the site root

  @id:documentation.theme-branding.001 @rule:docs.theme.single-accent-palette @inferred @source:docs/stylesheets/extra.css#:root @questionable
  Scenario: The rendered docs and the splash page share one accent colour pair
    Given the site's accent pair is sky blue #38bdf8 and deep blue #0284c7
    When a reader opens the splash page and then the rendered docs
    Then the splash page heading and buttons use the #38bdf8 to #0284c7 gradient
    And the docs links and primary colour use #0284c7
    And interactive accents in the docs use #38bdf8

  @id:documentation.theme-branding.002 @rule:docs.theme.links-legible-in-both-schemes @inferred @source:docs/stylesheets/extra.css#[data-md-color-scheme="slate"]
  Scenario Outline: Links stay readable in both the light and the dark colour scheme
    Given the reader's colour scheme is <scheme>
    When the reader views a docs page containing links
    Then links are shown in <link_colour>
    And the page background is <background>

    Examples:
      | scheme | link_colour       | background                   |
      | light  | deep blue #0284c7 | the default light background |
      | dark   | sky blue #38bdf8  | near-black #0b0f1a           |

  @id:documentation.theme-branding.003 @rule:docs.theme.no-stand-in-logo @inferred @source:docs/stylesheets/extra.css#.md-header__button.md-logo
  Scenario: The docs header shows no borrowed placeholder logo
    Given the project has no logo configured
    When a reader views any docs page
    Then no logo icon appears in the header
    And no logo icon appears in the navigation title
