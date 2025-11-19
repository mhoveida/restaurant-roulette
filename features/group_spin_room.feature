Feature: Group Spin
  As a group of users
  We want to spin the wheel together
  So we get a shared restaurant recommendation

  Background:
    Given a room with code "1234" exists
    And I am the host in the spin room

  Scenario: Group spin page loads correctly
    Then I should see the group roulette wheel
    And I should see the "✨ Ready to Spin?" button
    And I should see the group voting section

  Scenario: Host clicks the spin button and sees loading state
    When I click "✨ Ready to Spin?"
    Then the group wheel should animate and spin
    And the group wheel should slow down gradually

  @javascript
  Scenario: Group spin result appears and UI updates
    When a spin result is broadcast for "Golden Sushi"
    Then I should see the restaurant popup for "Golden Sushi"
    And I should see "Golden Sushi" in the voting list

  @javascript
  Scenario: Group sees details in popup
    When a spin result is broadcast for "Golden Sushi"
    Then I should see the restaurant name
    And I should see the restaurant image
    And I should see the restaurant rating
