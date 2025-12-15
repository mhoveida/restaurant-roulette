Feature: Model Coverage Edge Cases

  Scenario: Room helper methods return correct values
    Given a room exists with code "1111" created by "John Doe"
    And "Guest User" has joined room "1111"
    Then the room should report having members
    And the room should not be complete

  Scenario: Vote helpers return correct states
    Given a room exists with code "2222" created by "John Doe"
    And the room is in the voting phase
    When the host records a vote for option 0
    Then the host should have voted
    And the host vote should not be confirmed

  Scenario: Vote counts are computed correctly
    Given a room exists with code "3333" created by "John Doe"
    And the room is in the voting phase
    When the host records a vote for option 0
    And the host confirms the recorded vote
    Then vote counts should include option 0

  Scenario: Winner helper selects a winner
    Given a completed room with a winner exists
    Then the room should have a winner

  Scenario: Restaurant helper methods handle empty data
    Given a restaurant exists with no categories or dietary restrictions
    Then the restaurant cuisine list should be empty
    And the restaurant should not have cuisine "Italian"
    And the dietary restrictions list should be empty

  Scenario: User helper methods return correct names
    Given a user exists with first name "Jane" and last name "Doe"
    Then the user's full name should be "Jane Doe"
    And the user's short name should be "Jane"

  Scenario: Login validation fails when credentials are missing
    Given a user login is validated without email or password
    Then login validation should fail
