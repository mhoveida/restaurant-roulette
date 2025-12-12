Feature: User Restaurant History
  As a logged-in user
  I want to view and manage my saved restaurants
  So that I can keep track of places I want to visit

  Background:
    Given I am logged in as a user
    And I have saved restaurants to my history

  Scenario: User can view their restaurant history
    When I click on "View History" in the dropdown menu
    Then I should be taken to my history page
    And I should see all restaurants I've marked as "I'm Going!"
    And each restaurant should show its details (name, rating, cuisines, address)

  Scenario: User sees empty state when no history
    Given I have no saved restaurants
    When I navigate to my history page
    Then I should see an empty state message
    And I should see a link to go to Solo Spin

  # SKIPPED: Delete functionality requires JavaScript asset loading in test environment
  # @skip @javascript
  # Scenario: User can remove a restaurant from history
  #   When I click the remove button on a restaurant card
  #   And I confirm the deletion
  #   Then that restaurant should be removed from my history
  #   And the card should disappear with animation

  Scenario: Restaurant history shows when it was saved
    When I view my history
    Then each restaurant should display the date it was saved
    And they should be ordered with most recent first

  @javascript
  Scenario: User can view restaurant on map from history
    When I click the "View on Map" button for a restaurant
    Then Google Maps should open with that restaurant's location
    And the map should open in a new tab
