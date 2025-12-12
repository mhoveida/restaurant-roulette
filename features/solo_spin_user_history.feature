Feature: Solo Spin User History
  As a user
  I want to save restaurants I'm interested in from the solo spin
  So that I can keep track of places I want to visit

  Background:
    Given I am logged in as a user
    And I am on the solo spin page

  @javascript
  Scenario: User sees "I'm Going!" button when result is displayed
    When I set my preferences and spin the wheel
    And a restaurant result is shown
    Then I should see an "I'm Going!" button
    And the button should be green

  @javascript
  Scenario: User successfully saves a restaurant to history
    When I set my preferences and spin the wheel
    And a restaurant result is shown
    And I click the "I'm Going!" button
    Then the restaurant should be saved to my history
    And I should see a success message

  @javascript
  Scenario: User cannot save duplicate restaurants
    Given I have already saved a restaurant to my history
    When I spin the wheel and get the same restaurant
    And I click the "I'm Going!" button
    Then the button should show "Already in your history"
    And no duplicate entry should be created

  # @skip @javascript
  # Scenario: Guest users don't see "I'm Going!" button
  #  When I am not logged in
  #  And I set my preferences and spin the wheel
  #  And a restaurant result is shown
  #  Then I should not see an "I'm Going!" button
  #  And I should only see "View on Map" and "Share" buttons
