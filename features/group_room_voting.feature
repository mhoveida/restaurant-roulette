Feature: Group Room Spinning and Voting
  As a room member
  I want to spin the wheel multiple times and vote on options
  So that my group can collectively decide on a restaurant

  Background:
    Given the restaurant service is available
    And I am logged in as "Maddison"
    And I have created a room with code "8865"
    And members "Olivia, Celine, Ben" have joined

  Scenario: Room owner initiates spinning phase
    Given I am on the room waiting page
    When I click "Start Spin"
    Then I should be redirected to the group spin page
    And I should see the roulette wheel
    And I should see "Share this code with your friends"
    And I should see "Room Code: 8865"
    And I should see "Members in Room:" section

  Scenario: Room displays spin instruction
    Given I am on the group spin page
    Then I should see "Spin to add options for the group to vote on."
    And the spin button on the wheel should be visible

  Scenario: Owner spins the wheel first time
    Given I am on the group spin page
    And no options have been added yet
    When I click "Spin" on the wheel
    Then the wheel should animate and spin
    And the wheel should slow down gradually
    And the restaurant should be added to the voting board

  Scenario: First restaurant option is displayed
    Given the owner has spun once
    Then I should see "Voting Board" section
    And I should see "Option 1" label
    And I should see the restaurant name "Da Andrea"
    And I should see the restaurant image
    And I should see "Italian Restaurant"
    And I should see the rating "4.7" with stars
    And I should see the address "160 8th Ave, New York, NY 10011"
    And I should see the price range "$$"

  Scenario: Owner spins the wheel second time
    Given I have one option on the voting board
    When I click "Spin" on the wheel again
    Then a second restaurant should be added
    And I should see "Option 2" with restaurant details

  Scenario: Owner spins the wheel third time
    Given I have two options on the voting board
    When I click "Spin" on the wheel again
    Then a third restaurant should be added
    And I should see "Option 3" with restaurant details

  Scenario: Voting board displays multiple options
    Given the owner has spun three times
    Then I should see "Option 1" with "Da Andrea"
    And I should see "Option 2" with "Bourbon and Branch"
    And I should see "Option 3" with "Shukette"
    And all options should have consistent formatting

  Scenario: Owner can spin more than three times
    Given I have three options on the voting board
    When I click "Spin" again
    Then a fourth option should be added
    And all four options should be displayed

  Scenario: Owner finalizes options
    Given I have added 3 or more restaurant options
    When I click "Finalize Options"
    Then the spinning phase should end
    And I should see "Voting Board" header change to include "Time to Vote"
    And all members should see the voting interface

  Scenario: Members see waiting state during spinning
    Given I am a member "Olivia" (not the owner)
    And the owner is in the spinning phase
    Then I should see "Voting Board"
    And I should see current options being added
    And I should see "Waiting for the host to add options..."
    But I should not see vote buttons yet

  Scenario: Voting phase begins for all members
    Given the owner has finalized options with 3 restaurants
    Then all members should see "Time to Vote" banner
    And all members should see the voting interface
    And I should see "How are they?" section with thumbs up/down buttons
    And I should be able to click on an option box to cast my vote

  Scenario: Member gives thumbs up to an option
    Given voting phase has begun
    And I am viewing the voting board
    When I click the thumbs up button for "Option 2"
    Then my positive feedback for "Option 2" should be recorded
    And my preferences should be updated for future recommendations
    And the option should NOT be highlighted in green
    And I should be able to give thumbs up to other options too

  Scenario: Member gives thumbs down to an option
    Given voting phase has begun
    When I click the thumbs down button for "Option 1"
    Then my negative feedback for "Option 1" should be recorded
    And this restaurant preference should be noted for future avoidance

  Scenario: Member votes by clicking option box
    Given voting phase has begun
    And I am viewing the voting board
    When I click on "Option 2" box
    Then "Option 2" should be highlighted in green
    And my vote should be recorded
    Then the vote counter should increment to show my vote
    And other options should not be highlighted

  Scenario: Member can change their vote
    Given voting phase has begun
    And I have voted for "Option 2" (box is green)
    When I click on "Option 3" box
    Then "Option 2" should no longer be highlighted
    And "Option 3" should be highlighted in green
    And my vote should be moved to "Option 3"
    And vote counters should update accordingly

  Scenario: Vote counts are displayed in real-time
    Given voting phase has begun
    And "Maddison" clicks on "Option 2" box to vote
    And "Olivia" clicks on "Option 2" box to vote
    And "Celine" clicks on "Option 2" box to vote
    And "Ben" does not vote for "Option 2"
    Then the vote counter increments with each vote

  Scenario: Owner can spin again during voting
    Given voting phase has begun
    And I am the room owner
    When I click "Spin Again" button
    Then a new option should be added to the voting board
    And all members should see the new option
    And members can vote on the new option

  Scenario: All members vote and decide
    Given voting phase has begun
    And all 4 members have cast their votes (clicked on option boxes)
    And "Option 2" has the most votes (3 out of 4 clicked on it)
    When the owner clicks "Finalize Decision"
    Then the winning restaurant should be announced
    And all members should be redirected to the final result page

  Scenario: Winning restaurant is displayed
    Given voting has been finalized
    And "Bourbon and Branch" won with most votes
    Then I should see "You are going to:"
    And I should see celebration emoji/icon
    And I should see "Bourbon and Branch" details
    And I should see "Open | Close at 10:00pm"
    And I should see the rating "4.5 (453 review)"
    And I should see the address "155 W 33rd St, New York, NY 10001"
    And I should see "Budget Friendly"
    And I should see category tags "American, Wine Bars, Cocktail Bars"

  Scenario: Members can share the final result
    Given I am viewing the final restaurant result
    When I click the share icon
    Then I should see share options
    And the shared message should include restaurant name and address

  Scenario: Members can navigate to restaurant on map
    Given I am viewing the final restaurant result
    When I click on the address "155 W 33rd St, New York, NY 10001"
    Then I should be redirected to a map application
    And the restaurant location should be shown

  Scenario: Tie vote scenario
    Given voting phase has begun
    And "Option 1" has 2 votes
    And "Option 2" has 2 votes
    When the owner clicks "Finalize Decision"
    Then I should see "It's a tie!"
    And I should see options to "Revote" or "Random Selection"

  Scenario: Owner breaks tie with random selection
    Given there is a tie between two options
    When the owner selects "Random Selection"
    Then one of the tied restaurants should be randomly selected
    And all members should see the winning restaurant

  Scenario: Owner initiates revote
    Given there is a tie between two options
    When the owner selects "Revote"
    Then voting should restart for all tied options
    And all members can vote again

  Scenario: Room member returns to home after decision
    Given the final restaurant has been decided
    When I click "Back to Home Page"
    Then I should be redirected to the home page

  Scenario: Real-time updates for all members
    Given I am member "Olivia"
    And "Maddison" (owner) just spun the wheel
    Then I should see the new option appear automatically
    And I should not need to refresh the page

  Scenario: Option displays complete restaurant information
    Given an option is added to the voting board
    Then each option card should display:
      | Field           | Example                            |
      | Option Number   | Option 1                          |
      | Image           | Restaurant photo                   |
      | Name            | Da Andrea                         |
      | Cuisine Type    | Italian Restaurant                |
      | Rating          | 4.7 with stars                    |
      | Address         | 160 8th Ave, New York, NY 10011   |
      | Price Range     | $$                                |
