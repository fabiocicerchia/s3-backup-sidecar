@domain:documentation @area:page-components @from:docs/stylesheets
Feature: Styling the documentation page components
  Lets readers see a branded home hero, call-to-action buttons and feature cards without the site fetching anything from third parties.

  Background:
    Given the reader is viewing the rendered documentation site

  @id:documentation.page-components.001 @rule:docs.components.no-network-assets @inferred @source:docs/stylesheets/extra.css#:root
  Scenario: The docs theme loads no fonts or assets from the network
    Given the reader's device has no web fonts from the site installed
    When the reader opens a docs page
    Then body text is shown in the device's system sans-serif font
    And code is shown in the device's system monospace font
    And the theme requests no web font, CDN file or analytics script

  @id:documentation.page-components.002 @rule:docs.components.hero-and-primary-buttons @inferred @source:docs/stylesheets/extra.css#.md-typeset .hero
  Scenario: The home page hero and primary buttons carry the accent gradient
    Given the home page has a hero section with a title, tagline and buttons
    When the reader opens the docs home page
    Then the hero title is centred and filled with the accent gradient
    And primary buttons are pill-shaped with the accent gradient and white text
    And a button rises slightly when the reader hovers over it

  @id:documentation.page-components.003 @rule:docs.components.feature-card-hover @inferred @source:docs/stylesheets/extra.css#.md-typeset .grid.cards > ul > li @questionable
  Scenario: Feature cards lift and take an accent border when hovered
    Given a docs page shows a grid of feature cards
    When the reader hovers over a feature card
    Then the card rises slightly with a soft shadow
    And the card border takes on the accent colour
    And card icons are shown in the accent colour
