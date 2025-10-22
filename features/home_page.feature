Feature: Home Page
  As a user (guest or logged in)
  I want to see the home page
  So that I can navigate to different features of Restaurant Roulette

  Scenario: Guest user views the home page
    Given I am on the home page
    Then I should see "RESTAURANT"
    And I should see "ULETTE"
    And I should see "Let the Wheel pick your next meal"

  Scenario: Home page displays navigation options
    Given I am on the home page
    Then I should see a "Solo Spin" button
    And I should see a "Create Room" button
    And I should see a "Join Room" button
    And I should see an "Enter Room Code" input field
    And I should see a "Log In" button in the header

  Scenario: Guest user views the roulette wheel graphic
    Given I am on the home page
    Then I should see the roulette wheel graphic

  Scenario: Guest user clicks Solo Spin button
    Given I am on the home page
    And I am not logged in
    When I click "Solo Spin"
    Then I should be on the solo spin page

  Scenario: Logged in user clicks Solo Spin button
    Given I am logged in as "Maddison"
    And I am on the home page
    When I click "Solo Spin"
    Then I should be on the solo spin page

  Scenario: Guest user clicks Create Room button
    Given I am on the home page
    And I am not logged in
    When I click "Create Room"
    Then I should be on the create room page

  Scenario: Logged in user clicks Create Room button
    Given I am logged in as "Maddison"
    And I am on the home page
    When I click "Create Room"
    Then I should be on the create room page

  Scenario: Logged in user joins room with valid code
    Given I am logged in as "Maddison"
    And a room exists with code "8865"
    And I am on the home page
    When I fill in "Enter Room Code" with "8865"
    And I click "Join Room"
    Then I should be redirected to the group room page

  Scenario: Guest user tries to join room from home page
    Given I am not logged in
    And a room exists with code "8865"
    And I am on the home page
    When I fill in "Enter Room Code" with "8865"
    And I click "Join Room"
    Then I should be redirected to the join room page

  Scenario: Logged in user enters invalid room code
    Given I am logged in as "Maddison"
    And I am on the home page
    When I fill in "Enter Room Code" with "0000"
    And I click "Join Room"
    Then I should see "Room not found"
    And I should remain on the home page
    And the room code field should remain filled with "0000"

  Scenario: Logged in user submits empty room code
    Given I am logged in as "Maddison"
    And I am on the home page
    When I click "Join Room" without entering a code
    Then I should see "Please enter a room code"

  Scenario: User tries to join room with invalid format code
    Given I am logged in as "Olivia"
    And I am on the home page
    When I fill in "Enter Room Code" with "ABC"
    And I click "Join Room"
    Then I should see "Please enter a valid 4-digit room code"

  Scenario: Logged in user accesses profile menu
    Given I am logged in as "Maddison"
    And I am on the home page
    When I click on the user profile icon
    Then I should see a dropdown menu with profile options
    And I should see "View History"
    And I should see "Log Out"