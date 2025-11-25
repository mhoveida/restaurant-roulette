Feature: Group Room Functionality
  As a user
  I want to create and join group rooms
  So that I can coordinate restaurant choices with friends

  Background:
    Given the restaurant database has test data

  # ==========================================
  # ROOM CREATION SCENARIOS
  # ==========================================

  @javascript
  Scenario: Guest creates a room successfully
    Given I am not logged in
    And I am on the home page
    When I click "Create Room"
    Then I should be on the create room page
    And I should see "Create a Group Room"
    When I fill in "Name" with "John Doe"
    And I select "SoHo" from the "Neighborhood" dropdown
    And I select "$$" from the "Price Range" dropdown
    And I select "Italian" from the cuisine grid
    And I submit the room form
    Then I should see "Room Waiting Area"
    And I should see "Room Code"
    And I should see "Group Preferences"
    And I should see "John Doe" in the room creator field
    And I should see "SoHo" in the location field
    And I should see "$$" in the price field

  @javascript
  Scenario: Logged-in user creates a room with pre-filled name
    Given I am authenticated as "Jane Smith"
    And I am on the home page
    When I click "Create Room"
    Then the "Name" field should be read-only
    And the "Name" field should contain "Jane"

  @javascript
  Scenario: Room creation fails without required fields
    Given I am not logged in
    And I am on the home page
    When I click "Create Room"
    And I fill in "Name" with "John Doe"
    And I click "Create Room"
    Then I should see a validation message
    And I should remain on the create room page

  @javascript
  Scenario: Room creation fails without location
    Given I am not logged in
    And I am on the home page
    When I click "Create Room"
    And I fill in "Name" with "John Doe"
    And I select "$$" from the "Price Range" dropdown
    And I select "Italian" from the cuisine grid
    And I click "Create Room"
    Then I should see a validation message

  @javascript
  Scenario: Room creation fails without price
    Given I am not logged in
    And I am on the home page
    When I click "Create Room"
    And I fill in "Name" with "John Doe"
    And I select "SoHo" from the "Neighborhood" dropdown
    And I select "Italian" from the cuisine grid
    And I click "Create Room"
    Then I should see "Please fill in all fields"

  @javascript
  Scenario: Room receives unique 4-digit code
    Given I am not logged in
    And I am on the home page
    When I click "Create Room"
    And I fill in "Name" with "John Doe"
    And I select "SoHo" from the "Neighborhood" dropdown
    And I select "$$" from the "Price Range" dropdown
    And I select "Italian" from the cuisine grid
    And I click "Create Room"
    Then I should see a 4-digit room code
    And the room code should be unique

  # ==========================================
  # JOINING ROOM SCENARIOS
  # ==========================================

  @javascript
  Scenario: User joins room with valid code as guest
    Given a room exists with code "1234"
    And I am not logged in
    And I am on the home page
    When I fill in "Enter Room Code" with "1234"
    And I submit the join room form
    Then I should see "Set your preferences"
    And I should see "Join Room: 1234"

  @javascript
  Scenario: Joining room fails with invalid code format
    Given I am on the home page
    When I fill in "Enter Room Code" with "123"
    And I click "Join Room"
    Then I should see "Please enter a valid 4-digit room code"
    And I should remain on the home page

  @javascript
  Scenario: Joining room fails with non-existent code
    Given I am on the home page
    When I fill in "Enter Room Code" with "9999"
    And I click "Join Room"
    Then I should see "Room not found"

  @javascript
  Scenario: Joining room fails without entering code
    Given I am on the home page
    When I click "Join Room"
    Then I should see "Please enter a room code"

  @javascript
  Scenario: Logged-in user joins room directly
    Given I am logged in as "Jane Smith"
    And a room exists with code "1234"
    And I am on the home page
    When I fill in "Enter Room Code" with "1234"
    And I click "Join Room"
    Then I should see "Room Waiting Area"
    And I should see "Jane Smith" in the members list

  @javascript
  Scenario: Guest completes join with all preferences
    Given a room exists with code "1234" created by "John Doe"
    And I am not logged in
    And I am on the home page
    When I fill in "Enter Room Code" with "1234"
    And I click "Join Room"
    Then I should see "Set your preferences"
    
    When I fill in "Name" with "Guest User"
    And I select "West Village" from the "Neighborhood" dropdown
    And I select "$$$" from the "Price Range" dropdown
    And I select "French" from the cuisine grid
    And I click "Join Room"
    Then I should see "Room Waiting Area"
    And I should see "Guest User" in the members list
    And I should see "2 people in room"

  @javascript
  Scenario: Guest join fails without name
    Given a room exists with code "1234" created by "John Doe"
    And I am not logged in
    And I visit the join page for room "1234"
    When I select "SoHo" from the "Neighborhood" dropdown
    And I select "$$" from the "Price Range" dropdown
    And I select "Italian" from the cuisine grid
    And I click "Join Room"
    Then I should see "Please enter your name"

  @javascript
  Scenario: Guest join fails without location
    Given a room exists with code "1234" created by "John Doe"
    And I am not logged in
    And I visit the join page for room "1234"
    When I fill in "Name" with "Guest User"
    And I select "$$" from the "Price Range" dropdown
    And I select "Italian" from the cuisine grid
    And I click "Join Room"
    Then I should see "Please enter your location"

  # ==========================================
  # ROOM WAITING AREA
  # ==========================================

  @javascript
  Scenario: Room creator sees start button in waiting area
    Given I am logged in as "John Doe"
    And I have created a room with code "1234"
    Then I should see "Room Waiting Area"
    And I should see "✨ Start Spinning!" button
    And I should see "1 person in room"

  @javascript
  Scenario: Guest sees waiting message for creator to start
    Given a room exists with code "1234" created by "John Doe"
    And I am logged in as "Guest User"
    And I have joined room "1234"
    Then I should see "Waiting for John Doe to start spinning"
    And I should not see "Start Spinning!" button

  @javascript
  Scenario: Multiple guests join room
    Given a room exists with code "1234" created by "John Doe"
    And "Alice" has joined room "1234"
    And "Bob" has joined room "1234"
    When I am logged in as "Charlie"
    And I join room "1234"
    Then I should see "4 people in room"
    And I should see "John Doe" in the members list
    And I should see "Alice" in the members list
    And I should see "Bob" in the members list
    And I should see "Charlie" in the members list

  @javascript
  Scenario: Room displays all member badges correctly
    Given a room exists with code "1234" created by "John Doe"
    And "Guest User" has joined room "1234"
    When I visit room "1234"
    Then I should see "Room Creator" badge for "John Doe"
    And I should see "Member" badge for "Guest User"

  @javascript
  Scenario: Room code can be copied to clipboard
    Given I have created a room with code "1234"
    When I click "📋 Copy Room Code"
    Then the room code "1234" should be copied to clipboard
    And I should see "Room code 1234 copied to clipboard!"

  # ==========================================
  # SPINNING PHASE
  # ==========================================

  @javascript
  Scenario: Room creator starts spinning phase
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    When I click "✨ Start Spinning!"
    Then I should see "Taking Turns Spinning!"
    And I should see "Turn Order:"
    And I should see my turn indicator

  @javascript
  Scenario: Members take turns spinning
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the spinning phase has started
    When it is my turn to spin
    And I click "🎲 Spin the Wheel!"
    Then the wheel should spin
    And I should see a restaurant result
    And the next person's turn should begin

  @javascript
  Scenario: User cannot spin when it's not their turn
    Given a room exists with code "1234" created by "John Doe"
    And I have joined room "1234" as "Guest User"
    And the spinning phase has started
    When it is not my turn
    Then I should see "waiting for their turn" message
    And the spin button should be disabled

  @javascript
  Scenario: Current turn is highlighted in turn order
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the spinning phase has started
    When it is my turn to spin
    Then my name should be highlighted in turn order
    And I should see the current turn indicator

  @javascript
  Scenario: Completed turns show checkmark
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the spinning phase has started
    When I complete my spin
    Then I should see a checkmark next to my name
    And the turn should advance to the next member

  @javascript
  Scenario: Late joiner cannot spin after phase starts
    Given a room exists with code "1234" created by "John Doe"
    And the spinning phase has started
    When I try to join room "1234" as "Late User"
    Then I should see the room
    But I should not be in the turn order
    And I should see "joined after spinning started" message

  # ==========================================
  # REVEALING PHASE
  # ==========================================

  @javascript
  Scenario: Reveal phase begins after all spins complete
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the spinning phase has started
    When all members complete their spins
    Then I should see "Get Ready for the Big Reveal!"
    And I should see the reveal countdown

  @javascript
  Scenario: Room creator triggers reveal
    Given I have created a room with code "1234"
    And all members have completed spinning
    When I click "🎉 Reveal All Options!"
    Then I should see a countdown from 3
    And the voting phase should begin

  @javascript
  Scenario: Non-creator waits for reveal
    Given a room exists with code "1234" created by "John Doe"
    And I have joined room "1234" as "Guest User"
    And all members have completed spinning
    Then I should see "Waiting for John Doe to reveal options"
    And I should not see "Reveal All Options!" button

  # ==========================================
  # VOTING PHASE
  # ==========================================

  @javascript
  Scenario: Members vote on revealed options
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the voting phase has begun
    When I click on the first restaurant option
    Then that option should be highlighted
    And I should see "Confirm My Vote" button

  @javascript
  Scenario: User changes vote before confirming
    Given I am in the voting phase of room "1234"
    When I click on option 1
    And I click on option 2
    Then option 2 should be selected
    And option 1 should not be selected

  @javascript
  Scenario: User confirms their vote
    Given I am in the voting phase of room "1234"
    When I click on option 1
    And I click "Confirm My Vote"
    Then I should see "Vote Confirmed!"
    And the button should be disabled
    And I should not be able to change my vote

  @javascript
  Scenario: Vote counts update in real-time
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the voting phase has begun
    When I vote for option 1
    And "Guest User" votes for option 2
    Then option 1 should show "1 vote"
    And option 2 should show "1 vote"

  @javascript
  Scenario: All members must confirm votes
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the voting phase has begun
    When I confirm my vote for option 1
    But "Guest User" has not voted yet
    Then I should still see the voting interface
    And the winner should not be revealed yet

  @javascript
  Scenario: Partial match indicators shown during voting
    Given I am in the voting phase of room "1234"
    And option 1 is a location-only match
    When I view the voting options
    Then I should see "📍 Same area only" indicator for option 1

  # ==========================================
  # COMPLETE PHASE (Winner Selection)
  # ==========================================

  @javascript
  Scenario: Winner is selected after all votes
    Given I have created a room with code "1234"
    And "Guest User" has joined room "1234"
    And the voting phase has begun
    When I confirm my vote for option 1
    And "Guest User" confirms their vote for option 1
    Then I should see "🎉 You're going to:"
    And I should see the winning restaurant name
    And I should see "2 of 2 votes"

  @javascript
  Scenario: Winner shows which member suggested it
    Given the voting has completed in room "1234"
    And option 1 won with 2 votes
    And option 1 was suggested by "John Doe"
    Then I should see "Added by John Doe"

  @javascript
  Scenario: Tie is broken randomly
    Given I have created a room with code "1234"
    And "Guest1" has joined room "1234"
    And "Guest2" has joined room "1234"
    And the voting phase has begun
    When I vote for option 1
    And "Guest1" votes for option 2
    And "Guest2" votes for option 3
    And all votes are confirmed
    Then a winner should be randomly selected
    And I should see "🎲 Tie between 3 options - randomly selected!"

  @javascript
  Scenario: Winner displays full restaurant details
    Given the voting has completed in room "1234"
    And a winner has been selected
    Then I should see the restaurant name
    And I should see the star rating
    And I should see the price range
    And I should see the cuisine tags
    And I should see the address
    And I should see the status (Open/Closed)

  @javascript
  Scenario: Winner shows partial match type if applicable
    Given the voting has completed in room "1234"
    And the winner is a location-price match
    Then I should see "📍 Matched area & price"

  @javascript
  Scenario: User can view winner on Google Maps
    Given the voting has completed in room "1234"
    When I click "🗺️ View on Map"
    Then a new tab should open with Google Maps
    And the restaurant address should be in the search

  @javascript
  Scenario: User can share winner details
    Given the voting has completed in room "1234"
    When I click "Share"
    Then the restaurant details should be copied to clipboard
    And the native share dialog should appear

  # ==========================================
  # REAL-TIME UPDATES
  # ==========================================

  @javascript
  Scenario: Room updates when new member joins
    Given I have created a room with code "1234"
    When "Guest User" joins the room
    Then I should see "2 people in room" without refreshing
    And "Guest User" should appear in the members list

  @javascript
  Scenario: Turn indicator updates when someone spins
    Given I am in the spinning phase of room "1234"
    And it is not my turn
    When the current person completes their spin
    Then the turn order should update
    And the next person's turn should be highlighted

  @javascript
  Scenario: Votes update in real-time for all members
    Given I am in the voting phase of room "1234"
    When another member votes
    Then I should see the vote count increase
    And I should not need to refresh the page

  # ==========================================
  # EDGE CASES
  # ==========================================

  @javascript
  Scenario: Room persists across page refreshes
    Given I have created a room with code "1234"
    When I refresh the page
    Then I should still see "Room Waiting Area"
    And my room should retain all settings

  @javascript
  Scenario: User can access room directly via URL
    Given a room exists with code "1234" created by "John Doe"
    When I visit the room URL directly
    Then I should see "Room Waiting Area"
    And I should be prompted to join as guest

  @javascript
  Scenario: Room handles member without preferences gracefully
    Given a room exists with code "1234"
    When a member joins without setting all preferences
    Then the system should use room defaults
    And the member should still be able to spin

  @javascript
  Scenario: Single member room completes successfully
    Given I have created a room with code "1234"
    And no one else joins
    When I start spinning and complete my spin
    Then I should proceed to reveal
    And I should be able to vote
    And the winner should be selected

  @javascript
  Scenario: Room with 5+ members handles turn order correctly
    Given I have created a room with code "1234"
    And 5 guests have joined the room
    When the spinning phase starts
    Then all 6 members should be in turn order
    And each should get exactly one turn
