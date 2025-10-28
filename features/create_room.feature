Feature: Create Room
  As a user (guest or logged in)
  I want to create a group room
  So that I can coordinate restaurant selection with my friends

  Background:
    Given the restaurant service is available

  Scenario: Guest user accesses create room page
    Given I am not logged in
    And I am on the home page
    When I click "Create Room"
    Then I should be on the create room page
    And I should see "Create a Group Room"
    And I should see "Coordinate with your friend"
    And the name field should be empty

  Scenario: Logged in user accesses create room page
    Given I am logged in as "Maddison"
    And I am on the home page
    When I click "Create Room"
    Then I should be on the create room page
    And I should see "Create a Group Room"
    And I should see "Coordinate with your friend"

  Scenario: Owner name is pre-filled for logged in user
    Given I am logged in as "Maddison"
    And I am on the create room page
    Then the owner name field should display "Maddison"
    And the owner name field should be read-only

  Scenario: Owner name is empty for guest user
    Given I am not logged in
    And I am on the create room page
    Then the owner name field should be empty
    And the owner name field should be editable

  Scenario: User views create room form fields
    Given I am logged in as "Maddison"
    And I am on the create room page
    Then I should see an owner name field with "Maddison"
    And I should see a location input field with search icon
    And I should see a price range dropdown
    And I should see a cuisine preferences dropdown
    And I should see a "Create Room" button

  Scenario: User fills out all room preferences
    Given I am logged in as "Maddison"
    And I am on the create room page
    When I fill in "Location" with "New York"
    And I select "$$" from "Price Range"
    And I select cuisines "Italian, American, Mediterranean"
    Then all required fields should be filled
    And the "Create Room" button should be enabled

  Scenario: User attempts to create room without location
    Given I am on the create room page
    When I fill in "Name" with "Celine"
    And I select "$$" from "Price Range"
    And I click "Create Room"
    Then I should see "Please enter a location"
    And the room should not be created

  Scenario: User attempts to create room without price range
    Given I am on the create room page
    When I fill in "Name" with "Ben"
    And I fill in "Location" with "New York"
    And I click "Create Room"
    Then I should see "Please select a price range"
    And the room should not be created

  Scenario: Guest user attempts to create room without name
    Given I am not logged in
    And I am on the create room page
    When I fill in "Location" with "New York"
    And I select "$$" from "Price Range"
    And I click "Create Room"
    Then I should see "Please enter your name"
    And the room should not be created

  @javascript
  Scenario: User selects multiple cuisine preferences
    Given I am logged in as "Olivia"
    And I am on the create room page
    When I click on the create room "Cuisine Preferences" dropdown
    And I select "Italian, American, Mediterranean" cuisine
    Then I should see "Italian" create room tag with X button
    And I should see "American" create room tag with X button
    And I should see "Mediterranean" create room tag with X button

  @javascript
  Scenario: User removes a selected cuisine preference
    Given I am logged in as "Maddison"
    And I am on the create room page
    And I have selected create room cuisines "Italian, American, Mediterranean"
    When I click the create room X button on "American"
    Then "American" should be removed
    And I should see remaining cuisines "Italian, Mediterranean"

  Scenario: Guest user creates room successfully
    Given I am not logged in
    And I am on the create room page
    When I fill in "Name" with "Alex"
    And I fill in "Location" with "New York"
    And I select "$$" from "Price Range"
    And I select cuisines "Italian, American, Mediterranean"
    And I click "Create Room"
    Then a new room should be created
    And I should be redirected to the room waiting page
    And I should see "Share this code with your friends"
    And I should see a unique room code
    And the room code should be 4 digits

  Scenario: Logged in user creates room successfully
    Given I am logged in as "Maddison"
    And I am on the create room page
    When I fill in "Location" with "New York"
    And I select "$$" from "Price Range"
    And I select cuisines "Italian, American, Mediterranean"
    And I click "Create Room"
    Then a new room should be created
    And I should be redirected to the room waiting page
    And I should see "Share this code with your friends"
    And I should see a unique room code
    And the room code should be 4 digits

  Scenario: Room code is displayed after creation
    Given I have created a room successfully
    Then I should see "Room Code: 8865"
    And the room code should have a copy icon
    And I should see "Members in Room:"
    And I should see "Maddison" as the first member

  Scenario: Room creator can copy room code
    Given I have created a room with code "8865"
    When I click the copy icon next to the room code
    Then I should see a confirmation that the room code was copied

  Scenario: Room displays current members
    Given I have created a room
    And other users have joined: "Olivia, Celine, Ben"
    Then I should see "Members in Room:"
    And I should see "Maddison"
    And I should see "Olivia"
    And I should see "Celine"
    And I should see "Ben"
    And members should be listed in order of joining

  Scenario: Room creator waits for members
    Given I have created a room
    And I am on the room waiting page
    Then I should see a "Ready to Spin?" button
    But the button should be enabled regardless of member count

  Scenario: Room creator can spin before others join
    Given I have created a room
    And no other members have joined
    When I click "Ready to Spin?"
    Then I should be able to proceed to the spinning phase
    And restaurant options should be generated based on my preferences

  Scenario: Room members list updates in real-time
    Given I have created a room with code "8865"
    And I am viewing the room waiting page
    When another user "Olivia" joins the room
    Then I should see "Olivia" appear in the members list
    And I should not need to refresh the page

  Scenario: Room creator initiates spinning phase
    Given I have created a room
    And members "Olivia, Celine, Ben" have joined
    When I click "Ready to Spin?"
    Then I should be redirected to the group room spin page
    And I should see the roulette wheel
    And I should see "Spin to add options for the group to vote on"

  Scenario: User cancels room creation
    Given I am on the create room page
    And I have filled in all preferences
    When I click the back button or logo
    Then I should return to the home page
    And no room should be created

  Scenario: Invalid location entry
    Given I am logged in as "Maddison"
    And I am on the create room page
    When I fill in "Location" with "XYZ123Invalid"
    And I select "$$" from "Price Range"
    And I click "Create Room"
    Then I should see "Please enter a valid location"
    And the room should not be created

  Scenario: Room creator identity is marked
    Given I have created a room as "Olivia"
    Then "Olivia" should be marked as "Owner" or "Host" in the members list
    And other members should see this designation
