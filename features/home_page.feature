Feature: Home Page
  As a visitor
  I want to see the home page
  So that I can navigate to different features of Restaurant Roulette

  Scenario: Visitor views the home page
    Given I am on the home page
    Then I should see "RESTAURANT"
    And I should see "ULETTE"
    And I should see "Let the Wheel pick your next meal"

  Scenario: Home page displays navigation options
    Given I am on the home page
    Then I should see a "Solo Spin" button
    And I should see a "Create Room" button
    And I should see a join room form

  Scenario: Visitor clicks Solo Spin button
    Given I am on the home page
    When I click "Solo Spin"
    Then I should be on the solo spin page

  Scenario: Visitor clicks Create Room button
    Given I am on the home page
    And I am logged in as a test user
    When I click "Create Room"
    Then I should be on the create room page

  Scenario: Visitor tries to create room without login
    Given I am on the home page
    When I click "Create Room"
    Then I should be redirected to the login page
    And I should see "You must be logged in"

  Scenario: Home page displays the roulette wheel
    Given I am on the home page
    Then I should see the roulette wheel graphic

  Scenario: Visitor uses join room form with valid code
    Given I am logged in as a test user
    And a room exists with code "8865"
    And I am on the home page
    When I fill in "Enter Room Code" with "8865"
    And I click "Join Room"
    Then I should see "You joined the room"

  Scenario: Visitor uses join room form with invalid code
    Given I am logged in as a test user
    And I am on the home page
    When I fill in "Enter Room Code" with "0000"
    And I click "Join Room"
    Then I should see "Room not found"