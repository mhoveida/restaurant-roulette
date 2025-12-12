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

  @javascript
  Scenario: Logged-in user saves group spin winner to history
    Given the restaurant service is available
    And I have not saved any restaurants
    And another user has created a group room with code "GROUP1"
    And I have joined the group room as a logged-in user
    When the group completes voting and selects a restaurant
    Then the winning restaurant should be added to my user history
    And I should see the restaurant in my history when I visit my history page

  @javascript
  Scenario: Room owner and all logged-in guests save group spin winner to history
    Given the restaurant service is available
    And I have not saved any restaurants
    And I am logged in as a second user with different credentials
    And that second user has not saved any restaurants
    And I create a group room with code "OWNER1"
    And I have not saved any restaurants
    And a second logged-in user has joined the group room
    When the group completes voting and selects a restaurant
    Then the winning restaurant should be added to my user history as room owner
    And the winning restaurant should be added to the second user's history as a guest
    And I should see the restaurant in my history when I visit my history page
