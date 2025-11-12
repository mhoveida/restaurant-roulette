Feature: Group Room Spinning and Voting
  As a group of friends choosing a restaurant
  I want to spin for restaurant options and vote together in real time
  So that we can easily decide where to eat

  Background:
    Given the restaurant service is available
    And I am logged in as "Maddison"
    And I have created a room with code "8865"
    And members "Olivia, Celine, Ben" have joined

  # ----------------------------
  # WAITING ROOM PHASE
  # ----------------------------

  Scenario: Host views waiting room
    Given I am on the group room waiting page
    Then I should see "Share this code with your friends"
    And I should see "Room Code: 8865"
    And I should see "Members in Room:"
    And I should see "Start Spin" button enabled
    And I should see "Maddison" listed

  Scenario: Guest joins the room
    Given I am a guest user named "Olivia"
    Then I should be redirected to the waiting room
    And I should see "Olivia" appear in the members list

  Scenario: Host starts the spin phase
    Given I am on the group room waiting page
    When I click "Start Spin"
    Then I should be redirected to the group spin page
    And all members should automatically follow to the spin page

  # ----------------------------
  # SPIN ROOM PHASE
  # ----------------------------

  Scenario: Group spin page setup
    Given I am on the group spin page
    Then I should see "You are voting as: Maddison"
    And I should see the roulette wheel
    And I should see "✨ Ready to Spin?" button
    And I should see "Group Voting" section
    And I should see "No restaurants spun yet" message

  @javascript
  Scenario: Host spins and adds first restaurant
    Given I am on the group spin page
    When I click "✨ Ready to Spin?" on the wheel
    Then the group wheel should animate and spin
    And the group wheel should slow down gradually
    And I should see the group result overlay appear
    And I should see a new restaurant card appear under "Group Voting"
    And the card should display the restaurant name, rating, price, and address

  @javascript
  Scenario: Host spins again to add another restaurant
    Given a restaurant has already been spun
    When I click "✨ Ready to Spin?" on the wheel again
    Then I should see a different restaurant result
    And multiple restaurant cards should now appear in "Group Voting"

  @javascript
  Scenario: Members see new restaurants live
    Given I am "Olivia" on the group spin page
    When the host spins again
    Then I should see the new restaurant appear automatically under "Group Voting"
    And I should not need to refresh the page

  # ----------------------------
  # VOTING PHASE
  # ----------------------------

  @javascript
  Scenario: Group voting begins after multiple spins
    Given at least two restaurants have been spun
    Then each restaurant card should display 👍 and 👎 buttons
    And I should see "Vote for your favorite restaurants!" message

  @javascript
  Scenario: Member votes thumbs up
    Given voting has started
    And I am "Celine" on the group spin page
    When I click the thumbs up button for "Da Andrea"
    Then my vote should be recorded
    And I should see the 👍 count increase by 1
    And all members should see the updated counts live

  @javascript
  Scenario: Member votes thumbs down
    Given voting has started
    And I am "Ben" on the group spin page
    When I click the thumbs down button for "Shukette"
    Then my vote should be recorded
    And I should see the 👎 count increase by 1
    And all members should see the updated counts live

  @javascript
  Scenario: Real-time voting synchronization
    Given "Maddison" votes 👍 for "Da Andrea"
    Then "Olivia" should immediately see the updated 👍 count

  # ----------------------------
  # CONTINUED SPINNING (OPTIONAL)
  # ----------------------------

  @javascript
  Scenario: Host continues spinning during voting
    Given voting has started
    And I am the host
    When I click "✨ Ready to Spin?" on the wheel again
    Then a new restaurant card should be added under "Group Voting"
    And all members should see it appear live
    And all members can vote on it immediately

  # ----------------------------
  # RESULTS
  # ----------------------------

  @javascript
  Scenario: Display results live as voting progresses
    Given voting has started
    And members are voting in real time
    Then each restaurant card should show live 👍 and 👎 counts updating
    And no refresh should be required
    And I should see the restaurant with the highest votes highlighted
