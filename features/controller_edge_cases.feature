Feature: Controller edge cases for coverage

  Scenario: Cannot start spinning twice
    Given a room exists with code "4444" created by "John Doe"
    And the room has already started spinning
    When the host attempts to start spinning again
    Then the start spinning request should fail

  Scenario: Cannot spin when it is not your turn
    Given a room exists with code "5555" created by "John Doe"
    And the room is spinning
    When the non current member attempts to spin
    Then the spin should fail

  Scenario: Cannot reveal before spinning finishes
    Given a room exists with code "6666" created by "John Doe"
    When the host attempts to reveal options early
    Then the reveal should fail

  Scenario: Confirm vote fails without prior vote
    Given a room exists with code "8888" created by "John Doe"
    And the room is in the voting phase
    When the host confirms a vote without voting
    Then the confirmation should fail

  Scenario: Cannot start a new round when not complete
    Given a room exists with code "9999" created by "John Doe"
    When the host attempts to start a new round early
    Then the new round request should fail

  Scenario: Completing a round broadcasts a winner and reports confirmed votes
    Given a room exists with code "1010" created by "John Doe"
    And "Guest User" has joined room "1010"
    And the room has finished spinning and revealed options
    And the host session is established
    When the host submits a valid vote for option 0
    And the guest records a vote for option 0
    And the host finalizes their vote
    And the guest confirms the recorded vote
    And voting is completed
    And the client requests the room status
    Then the room should have a winner
    And the confirmed vote count should be 2

  Scenario: Guest cannot join a room without dietary restrictions
    Given a room exists with code "2020" created by "John Doe"
    When a guest attempts to join room "2020" with categories but no dietary restrictions
    Then the guest should see an error asking to select a dietary option
