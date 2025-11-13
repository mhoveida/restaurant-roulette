Feature: Group Room Spin
  As a user
  I want to spin the roulette wheel in a group room
  So that the group can get restaurant recommendations

  Background:
    Given the restaurant service is available

  Scenario: Room creator can spin restaurant
    Given I have created a room
    When I click "Ready to Spin?"
    Then I should see a spinning wheel
    And the wheel should generate a restaurant result

  Scenario: Guest member can view room after joining
    Given I have created a room with code "1234"
    And I am not logged in
    When I am on the join as guest page for the room
    And I fill in "guest_name" with "Test Guest"
    And I click "Join Room"
    Then I should be redirected to the room
    And I should see "Room Waiting Area"

  Scenario: Room code is unique for each room
    Given I have created a room successfully
    And I have created another room
    Then the room codes should be different
