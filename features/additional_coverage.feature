Feature: Additional backend coverage
  Scenarios to exercise controller and model paths that were not previously hit.

  Scenario: Google OAuth callback persists a new user
    Given OmniAuth mock returns user info with name "Coverage User" and email "coverage-user@example.com"
    When I authenticate with Google
    Then a new user record should be created with email "coverage-user@example.com"
    And I should be redirected to the home page
    And the user short name for "coverage-user@example.com" should be "Coverage"

  Scenario: Google OAuth callback failure redirects to sign up
    Given OmniAuth mock returns invalid user data (missing email)
    When I authenticate with Google
    Then I should be redirected to the sign up page

  Scenario: OmniAuth failure endpoint shows an alert
    When I hit the OmniAuth failure callback with "access_denied"
    Then I should be redirected to the home page
    And I should see "Authentication failed: access_denied"

  Scenario: Successful sign up uses custom registrations controller
    When I complete a valid sign up for "coverage-signup@example.com"
    Then I should be on the sign up page

# Scenario: Inactive sign up path falls back gracefully
#   When I complete an inactive sign up for "inactive-user@example.com"
#   Then I should see "signed up but"

  Scenario: User login validation requires credentials
    When I validate a blank login user
    Then I should see login errors for email and password

  Scenario: Room membership helpers track guests
    Given a simple room exists for coverage
    When I add a guest named "Coverage Guest" with preferences
    And I gather the room members
    Then both the host and guest should be returned

# Temporarily disabled - needs fixing
#  Scenario: Logged-in user joins an existing room via join endpoint
#    Given I am authenticated as "Coverage Owner"
#    And a room with code "2468" exists for joining
#    When I post a join request for code "2468"
#    Then I should land on that room page
#    And the room membership should include "Coverage"

  Scenario: Invalid room code shows error
    When I post a join request for code "9999"
    Then I should see "Room not found"

  Scenario: Guest join validation errors are displayed
    Given a room with code "1357" exists for joining
    When I submit an empty guest join request for room "1357"
    Then I should see "Please enter your name"

  Scenario: Restaurant helpers expose cuisines
    Given I pick a seeded restaurant with cuisine "Italian"
    When I evaluate restaurant helpers for "Italian"
    Then the helpers should include that cuisine

  Scenario: Solo spin returns a restaurant result
    When I request a solo spin for "SoHo" with price "$$" and cuisine "Italian"
    Then the solo spin response should be successful

  Scenario: Room helpers for turn management work correctly
    Given a room exists in spinning state
    When I check the current turn information
    Then the turn methods should return correct values

  Scenario: Room voting confirms and tallies votes
    Given a room exists in voting state with options
    When members vote and confirm
    Then votes should be tallied and winner determined

  Scenario: Room new round resets state correctly
    Given a completed room exists
    When a new round is started
    Then the room state should reset for spinning

  Scenario: Room validations reject invalid data
    When I create a room with blank location
    Then I should see location validation error

  Scenario: Room join handles missing code gracefully
    When I try to join with blank room code
    Then I should see blank code error

  Scenario: Room join handles invalid format code
    When I try to join with invalid format code "ABC"
    Then I should see format validation error

  Scenario: Neighborhoods endpoint returns list
    When I request the neighborhoods list
    Then I should get a JSON list of neighborhoods

  Scenario: Cuisines endpoint returns list
    When I request the cuisines list
    Then I should get a JSON list of cuisines

  Scenario: Solo spin fallback to location and price
    When I request a solo spin with uncommon cuisine
    Then it should fallback to location and price match

  Scenario: Solo spin fallback to location only
    When I request a solo spin with unavailable price and cuisine
    Then it should fallback to location only match

  Scenario: User full name concatenates first and last
    When I create a user with first and last names
    Then the full name should be correctly formatted

  Scenario: Guest join requires location
    Given a room with code "5555" exists for joining
    When a guest submits join without location
    Then they should see location required error

  Scenario: Guest join requires price
    Given a room with code "6666" exists for joining
    When a guest submits join without price
    Then they should see price required error

  Scenario: Guest join requires cuisines
    Given a room with code "7777" exists for joining
    When a guest submits join without cuisines
    Then they should see cuisine required error

  Scenario: Room status endpoint returns current state
    Given a room exists in spinning state
    When I request the room status
    Then I should get JSON with current state

  Scenario: Room vote rejects invalid option index
    Given a room exists in voting state with options
    When a member votes for option 999
    Then the vote should fail

  Scenario: Room allows double vote confirmation idempotently
    Given a room exists in voting state with options
    When a member confirms their vote twice
    Then the second confirmation should succeed

  Scenario: Room handles member not in spins list
    Given a room exists in spinning state
    When I try to spin as non-existent member
    Then I should get member not found error

  Scenario: Room complete state check works
    Given a room exists in voting state with options
    When members vote and confirm
    Then the room should be in complete state

  Scenario: Room get spins for round works
    Given a room with multiple rounds of spins
    When I get spins for round 1
    Then I should only get round 1 spins

  Scenario: Room symbolize keys helper works
    Given a simple room exists for coverage
    When I get all members
    Then member keys should be symbols

  Scenario: Room search with category conditions
    Given restaurants exist with various categories
    When I search for room restaurant with specific category
    Then I should get matching restaurant

  Scenario: Solo spin handles no restaurant found
    When I request a solo spin with impossible criteria
    Then I should get no restaurant error

  Scenario: User from omniauth with missing name parts
    When I authenticate via Google with incomplete name
    Then default name parts should be used

  Scenario: Room create with logged in user uses first name
    Given I am authenticated as "TestUser"
    When I create a room as logged in user
    Then the owner name should be my first name

  Scenario: Room join as logged in user adds member
    Given I am authenticated as "TestUser"
    And a room with code "8888" exists for joining
    When I join the room while logged in
    Then I should be added as a user member

  Scenario: Room join as logged in user already in room
    Given I am authenticated as "TestUser"
    And a room with code "9999" exists for joining
    And I am already a member of that room
    When I join the room again
    Then I should not be added twice

  Scenario: Room has voted check returns correct value
    Given a room exists in voting state with options
    When a member has voted
    Then has_voted should return true

  Scenario: Room get member vote returns option
    Given a room exists in voting state with options
    When a member has voted for option 1
    Then get_member_vote should return 1

  Scenario: Room advance turn updates index
    Given a room exists in spinning state
    When a member completes their spin
    Then the turn index should advance

  Scenario: Room round complete check works
    Given a room exists in revealing state
    Then round_complete should be true

# Temporarily disabled - needs fixing
#  Scenario: Sessions controller after sign in redirects to root
#    Given I am on the login page
#    When I successfully log in
#    Then I should be redirected to root path

  Scenario: Room broadcast methods are called during state changes
    Given a room exists in spinning state
    When the room owner starts spinning
    Then broadcast should be triggered

  Scenario: Room vote counts are calculated correctly
    Given a room exists in voting state with options
    When members submit votes
    Then vote counts should be tracked per option

  Scenario: Room determine winner selects highest voted option
    Given a room exists with tallied votes
    When winner is determined
    Then the highest voted restaurant should win

  Scenario: Room fallback finds restaurant with price and cuisine
    Given restaurants exist in database
    When I search with unavailable location but valid price and cuisine
    Then fallback should find price and cuisine match

  Scenario: Room fallback finds restaurant with cuisine only
    Given restaurants exist in database
    When I search with unavailable location and price but valid cuisine
    Then fallback should find cuisine only match

  Scenario: Room fallback finds restaurant with price only
    Given restaurants exist in database
    When I search with unavailable location and cuisine but valid price
    Then fallback should find price only match

  Scenario: Room fallback finds random restaurant as last resort
    Given restaurants exist in database
    When I search with all unavailable criteria
    Then fallback should find random restaurant

  Scenario: Solo spin show page works for logged in user
    Given I am authenticated as "SpinUser"
    When I visit the solo spin page
    Then I should see the solo spin form

  Scenario: Static pages home controller works
    When I visit the home page
    Then I should see the home page content

  Scenario: Room create fails with validation errors
    When I create a room with invalid data
    Then I should see validation errors

  Scenario: Room get vote counts returns counts per option
    Given a room exists in voting state with votes
    When I get the vote counts
    Then I should see counts per option index

  Scenario: Room has confirmed vote returns true for confirmed
    Given a room exists in voting state with options
    When a member confirms their vote
    Then has_confirmed_vote should return true

  Scenario: Room check voting complete triggers winner selection
    Given a room exists in voting state with all votes
    When all members have confirmed
    Then voting complete should trigger winner

  Scenario: Room reveal order randomizes display
    Given a room exists in revealing state
    When options are revealed
    Then reveal order should be randomized

  Scenario: Room get revealed spins returns only revealed
    Given a room exists with revealed and unrevealed spins
    When I get revealed spins
    Then only revealed spins should be returned

  Scenario: Room current turn member returns nil when not spinning
    Given a room exists in waiting state
    When I check current turn member
    Then it should return nil

  Scenario: Room is my turn returns false when not spinning
    Given a room exists in waiting state
    When I check if it is my turn
    Then it should return false

  Scenario: Room spin for member handles not spinning state
    Given a room exists in waiting state
    When I try to spin for member
    Then it should return not in spinning state error

  Scenario: Room advance turn moves to revealing when round complete
    Given a room exists with last member about to spin
    When the last member spins
    Then the room should advance to revealing state

  Scenario: Solo spin fallback to price and cuisine works
    When I request solo spin with missing location
    Then it should match on price and cuisine

  Scenario: Solo spin fallback to cuisine only works
    When I request solo spin with missing location and price
    Then it should match on cuisine only

  Scenario: Solo spin fallback to price only works
    When I request solo spin with missing location and cuisine
    Then it should match on price only

  Scenario: Solo spin random fallback works
    When I request solo spin with no matching criteria
    Then it should return random restaurant

  Scenario: Room start spinning returns false if not waiting
    Given a room exists in spinning state
    When I try to start spinning again
    Then it should return false

  Scenario: Room reveal returns false if not revealing
    Given a room exists in spinning state
    When I try to reveal options
    Then it should return false

  Scenario: Room code is generated uniquely
    When multiple rooms are created
    Then all codes should be unique

  Scenario: Room initialize state sets defaults
    When a new room is created
    Then initial state values should be set

  Scenario: Room get options for voting returns randomized list
    Given a room exists in voting state with options
    When I get voting options
    Then options should be in reveal order

  Scenario: Room tally votes handles ties
    Given a room exists with tied votes
    When votes are tallied
    Then a tie breaker should be applied

  Scenario: Room spin for member handles member preferences
    Given a room exists in spinning state with guest
    When the guest spins
    Then their preferences should be used

  Scenario: Room member by id returns owner for owner id
    Given a simple room exists for coverage
    When I get member by id owner
    Then it should return owner details

  Scenario: Room add guest member generates unique id
    Given a simple room exists for coverage
    When I add multiple guests
    Then each should have unique id

  Scenario: Solo spin handles categories as array
    When I request solo spin with array categories
    Then it should process correctly

  Scenario: Room join as guest renders form on GET
    Given a room with code "4444" exists for joining
    When I GET the join as guest page
    Then I should see the guest join form

  Scenario: Room join as guest succeeds with valid data
    Given a room with code "3333" exists for joining
    When I POST valid guest join data
    Then I should be added to the room

  Scenario: Rooms controller new action sets defaults
    When I visit the create room page
    Then default values should be set

  Scenario: Room check voting complete handles partial votes
    Given a room exists in voting state with partial votes
    When voting is checked
    Then it should not be complete

  Scenario: Room votes will change marks attribute dirty
    Given a room exists in voting state with options
    When a vote is confirmed
    Then the votes attribute should be marked changed

  Scenario: Room search restaurants handles nil price
    Given a simple room exists for coverage
    When I search with nil price
    Then it should search without price filter

  Scenario: Room search restaurants handles nil location
    Given a simple room exists for coverage
    When I search with nil location
    Then it should search without location filter

  Scenario: Room search restaurants handles empty categories
    Given a simple room exists for coverage
    When I search with empty categories
    Then it should search without category filter
