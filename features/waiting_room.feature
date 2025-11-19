Feature: Waiting room and spin room flow
  As a guest joining an existing room
  I want to see the waiting room page
  So that I can join the group spin

  Background:
    Given a room with code "1234" exists with:
      | owner_name | Alice     |
      | location   | New York |
      | price      | $$        |
      | categories | Sushi,Thai |

  Scenario: Guest joins a room and starts the group spin
    When I visit the join page for room code "1234"
    And I enter guest name "Celine"
    And I submit the guest join form

    Then I should be on the waiting room page for code "1234"
    And I should see "Room Waiting Area"
    And I should see "Room Code: 1234"
    And I should see "Alice"
    And I should see "New York"
    And I should see "Sushi"
    And I should see "Thai"

    When I click "Ready to Spin?"
    Then I should be on the spin room page
    And I should see "Group Spin"
    And I should see "You are voting as: Celine"
