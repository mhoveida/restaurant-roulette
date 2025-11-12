Feature: Group Room Spinning and Voting
  As a group of friends choosing where to eat
  I want to spin for restaurant options and vote together
  So that we can decide on one restaurant fairly and easily

  Background:
    Given the restaurant service is available
    And I am logged in as "Maddison"
    And I have created a room with code "8865"
    And members "Olivia, Celine, Ben" have joined

  # --- WAITING ROOM FLOW ---

  Scenario: Room owner sees waiting room setup
    Given I am on the group room waiting page
    Then I should see "Share this code with your friends"
    And I should see "Room Code: 8865"
    And I should see "Members in Room:"
    And I should see "Ready to Spin?" button enabled
    And I should see the host name "Maddison" listed

  Scenario: Guest joins the waiting room
    Given I am a guest user named "Olivia"
    When I enter room code "8865"
    And I input my name as "Olivia"
    Then I should be redirected to the waiting room
    And I should see "Olivia" in the members list
    And I should see "Share this code with your friends"

  Scenario: Room members update in real time
    Given "Maddison" is on the waiting page
    When "Celine" joins the room
    Then "Maddison" should see "Celine" appear in the members list
    And no page reload should be required

  Scenario: Host starts the spinning phase
    Given all members are in the waiting room
    When the host clicks "Ready to Spin?"
    Then the host should be redirected to the group spin page
    And all other members should automatically follow to the same spin page
    And each member should see their correct name displayed

  # --- SPIN ROOM FLOW ---

  Scenario: Group spin page setup
    Given I am on the group spin page
    Then I should see "You are voting as: Maddison"
    And I should see the roulette wheel
    And I should see "Ready to Spin?" button under the wheel
    And I should see "Group Voting" section
    And I should see "No restaurants spun yet" message

  Scenario: Host spins for first restaurant
    Given I am the room host on the group spin page
    When I click "Ready to Spin?"
    Then the wheel should animate and slow down
    And a new restaurant card should appear under "Group Voting"
    And the restaurant details should include:
      | Field        | Example                            |
      | Name         | Da Andrea                         |
      | Price Range  | $$                                |
      | Rating       | 4.7                                |
      | Address      | 160 8th Ave, New York, NY 10011   |

  Scenario: Avoid duplicate restaurant suggestions
    Given I have already spun once
    When I click "Ready to Spin?" again
    Then I should get a different restaurant suggestion
    And the same restaurant should not appear twice

  Scenario: Multiple spins populate voting list
    Given I have spun three times
    Then I should see three restaurant cards
    And each should have unique names and images
    And all cards should display thumbs up/down buttons

  Scenario: Members see updates in real time
    Given I am "Olivia" on the spin page
    And the host spins for a new restaurant
    Then I should see the new restaurant card appear automatically
    And I should not need to refresh the page

  # --- VOTING PHASE FLOW ---

  Scenario: All members enter voting phase
    Given at least three restaurants have been spun
    When the host clicks "Finalize Options"
    Then all members should see "Time to Vote" banner
    And I should see thumbs up and thumbs down buttons for each option

  Scenario: Member casts a thumbs up
    Given the voting phase has started
    And I am "Celine"
    When I click the thumbs up button for "Da Andrea"
    Then my vote should be recorded
    And I should see the 👍 count increase by 1

  Scenario: Member casts a thumbs down
    Given the voting phase has started
    And I am "Ben"
    When I click the thumbs down button for "Shukette"
    Then my vote should be recorded
    And I should see the 👎 count increase by 1

  Scenario: Real-time vote synchronization
    Given "Maddison" and "Olivia" are on the spin room
    When "Maddison" votes 👍 for "Option 2"
    Then "Olivia" should immediately see the updated 👍 count

  Scenario: Member changes vote
    Given I have voted 👍 for "Da Andrea"
    When I click 👍 on "Bourbon and Branch"
    Then my previous vote should be removed from "Da Andrea"
    And the new vote should appear on "Bourbon and Branch"

  # --- FINAL DECISION FLOW ---

  Scenario: Host finalizes decision
    Given all members have voted
    And "Bourbon and Branch" has the most votes
    When the host clicks "Finalize Decision"
    Then all members should be redirected to the final result page
    And I should see "You are going to: Bourbon and Branch"
    And I should see the restaurant details and rating
    And I should see celebration animation or emoji

  Scenario: Tie-breaking logic
    Given "Da Andrea" and "Shukette" each have 2 votes
    When the host clicks "Finalize Decision"
    Then I should see "It's a tie!"
    And options for "Revote" and "Random Selection" should appear

  Scenario: Host resolves tie with random selection
    Given there is a tie between "Da Andrea" and "Shukette"
    When the host selects "Random Selection"
    Then one of the tied restaurants should be chosen as winner
    And all members should see the winning restaurant

  Scenario: Host initiates a revote
    Given there was a tie between two options
    When the host selects "Revote"
    Then voting restarts for those tied restaurants
    And all members can vote again

  Scenario: Return to home
    Given I am on the final result page
    When I click "Back to Home Page"
    Then I should be redirected to the home page
