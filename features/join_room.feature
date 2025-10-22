Feature: Join Room
  As a user (guest or logged in)
  I want to join an existing group room
  So that I can participate in group restaurant selection

  Background:
    Given the restaurant service is available

  Scenario: Guest user attempts to join room from home page
    Given I am not logged in
    And a room exists with code "8865"
    And I am on the home page
    When I fill in "Enter Room Code" with "8865"
    And I click "Join Room"
    Then I should be redirected to the join room page
    And I should see a name input field
    And I should see the room code field displaying "8865"
    And the room code field should be disabled
    And I should see "Enter your name to join"

  Scenario: Guest user joins room with name
    Given I am not logged in
    And a room exists with code "8865" created by "Maddison"
    And I am on the join room page with code "8865"
    Then I should see the room code field displaying "8865"
    And the room code field should be disabled
    When I fill in "Name" with "Ben"
    And I click "Join Room"
    Then I should be redirected to the group room page
    And I should see "You joined the room successfully"
    And I should see "Room Code: 8865"
    And I should see "Maddison" in the members list
    And I should see "Ben" in the members list

  Scenario: Join room page displays correctly for guest user
    Given I am not logged in
    And a room exists with code "8865"
    And I am on the join room page with code "8865"
    Then I should see "Group Room"
    And I should see "Coordinate with your friend"
    And I should see a name input field that is empty and editable
    And I should see a room code field displaying "8865"
    And the room code field should be disabled
    And I should see a "Ready to Vote?" button

  Scenario: Join room page displays correctly for logged in user
    Given I am logged in as "Olivia"
    And a room exists with code "8865"
    And I am on the join room page with code "8865"
    Then I should see the name field displaying "Olivia"
    And the name field should be read-only
    And I should see a room code field displaying "8865"
    And the room code field should be disabled
    And I should see a "Ready to Vote?" button

  Scenario: Logged in user joins room from home page (name pre-filled)
    Given I am logged in as "Olivia"
    And a room exists with code "8865" created by "Maddison"
    And I am on the home page
    When I fill in "Enter Room Code" with "8865"
    And I click "Join Room"
    Then I should be redirected to the group room page
    And I should see "You joined the room successfully"
    And I should see "Room Code: 8865"
    And I should see "Maddison" in the members list
    And I should see "Olivia" in the members list

  Scenario: User views join room page
    Given I am logged in as "Olivia"
    And I am on the join room page
    Then I should see "Group Room"
    And I should see "Coordinate with your friend"
    And I should see my name "Olivia"
    And I should see "Room Code:" input field
    And I should see "Members in Room:" section
    And I should see "Ready to Vote?" button

  Scenario: Join room page shows current room information
    Given I am logged in as "Olivia"
    And I have joined room "8865"
    Then the room code field should display "8865"
    And the room code should be read-only
    And I should see the current members list

  Scenario: New member appears in room members list
    Given "Maddison" has created room "8865"
    And "Maddison" is viewing the room page
    When "Olivia" joins the room
    Then "Maddison" should see "Olivia" appear in the members list
    And the update should happen in real-time without refresh

  Scenario: Multiple users join same room
    Given "Maddison" has created room "8865"
    When "Olivia" joins room "8865"
    And "Celine" joins room "8865"
    And "Ben" joins room "8865"
    Then all members should see each other:
      | Maddison |
      | Olivia   |
      | Celine   |
      | Ben      |

  Scenario: User joins room already in progress
    Given "Maddison" created room "8865"
    And room "8865" is in voting phase
    And I am logged in as "Olivia"
    When I join room "8865"
    Then I should be added to the room
    And I should see the current voting board
    And I should see "Time to Vote"
    And I should be able to vote immediately

  Scenario: User joins room after spinning phase started
    Given "Maddison" created room "8865"
    And "Maddison" has started spinning
    And there are already 2 options on the board
    When "Olivia" joins room "8865"
    Then "Olivia" should see the existing options
    And "Olivia" should see "Waiting for the host to add options..."

  Scenario: Late joiner sees options already added
    Given room "8865" has 3 options added
    And I am logged in as "Olivia"
    When I join room "8865"
    Then I should see all 3 existing options
    And I should see the current state of the room

  Scenario: User joins room then owner starts voting
    Given I am logged in as "Olivia"
    And I have joined room "8865"
    And I am on the room waiting page
    When the owner clicks "Ready to Spin?"
    Then I should automatically see the voting board

  Scenario: Member waits for owner to finalize options
    Given I am logged in as "Olivia"
    And I have joined room "8865"
    And the owner is adding options
    Then I should see "Waiting for the host to add options..."
    And I should not have access to the "Finalize Options" button

  Scenario: Member receives notification when voting starts
    Given I am logged in as "Olivia"
    And I am in room "8865"
    And the owner finalizes the options
    Then I should see "Time to Vote" message
    And voting buttons should appear for all options

  Scenario: User leaves room before voting
    Given I am logged in as "Olivia"
    And I have joined room "8865"
    When I click "Back to Home Page" or close the browser
    Then I should be removed from the room
    And other members should see the updated member count

  Scenario: User rejoins room after leaving
    Given I am logged in as "Olivia"
    And I was previously in room "8865"
    And I left the room
    When I enter room code "8865" again
    Then I should be able to rejoin
    And I should see the current state of the room

  Scenario: Room owner is indicated in members list
    Given I am logged in as "Olivia"
    And I have joined room "8865" created by "Ben"
    Then I should see "Ben" with an owner/host indicator
    And other members should not have this indicator

  Scenario: Share link validation
    Given "Maddison" has created room "8865"
    And "Maddison" shares the room link with friends
    When "Olivia" clicks the shared link
    And "Olivia" is logged in
    Then "Olivia" should join the room directly
    And should see "You joined the room successfully"

  Scenario: Room member sees real-time option additions
    Given I am logged in as "Olivia"
    And I have joined room "8865"
    And the owner is spinning the wheel
    When the owner adds "Option 1"
    Then I should see "Option 1" appear on my screen
    And the update should be instant without page refresh
