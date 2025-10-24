Feature: Solo Spin
  As a user
  I want to spin the roulette wheel individually
  So that I can get a restaurant recommendation based on my preferences

  Background:
    Given the restaurant service is available

  Scenario: Guest user accesses solo spin page
    Given I am not logged in
    And I am on the home page
    When I click "Solo Spin"
    Then I should be on the solo spin page
    And I should see "Set Your Preference"
    And I should see "Tell us what you're looking for"

  Scenario: Logged in user accesses solo spin with pre-filled name
    Given I am logged in as "Maddison"
    And I am on the home page
    When I click "Solo Spin"
    Then I should be on the solo spin page
    And the name field should display "Maddison"
    And the name field should be read-only

  Scenario: User views solo spin preference form
    Given I am on the solo spin page
    Then I should see a name input field
    And I should see a location input field with search icon
    And I should see a price range dropdown
    And I should see a cuisine preferences dropdown
    And I should see the roulette wheel
    And I should see a "Spin" button

  Scenario: User fills out all preferences successfully
    Given I am on the solo spin page
    When I fill in "Name" with "Maddison"
    And I fill in "Location" with "New York"
    And I select "$$" from "Price Range"
    And I select cuisines "Italian, American, Mediterranean"
    Then all required fields should be filled
    And the "Spin" button should be enabled

  Scenario: User selects price range options
    Given I am on the solo spin page
    When I click on "Price Range" dropdown
    Then I should see "$" option
    And I should see "$$" option
    And I should see "$$$" option
    And I should see "$$$$" option

  Scenario: User spins the wheel successfully
    Given I am on the solo spin page
    And I have filled in all required preferences:
      | Name     | Location | Price Range | Cuisines                    |
      | Maddison | New York | $$         | Italian, American, Mediterranean |
    When I click "Spin"
    Then the wheel should animate and spin
    And the wheel should slow down gradually
    And I should see the restaurant result page

  Scenario: User views restaurant result after spinning
    Given I have completed a solo spin with valid preferences
    When the wheel stops spinning
    Then I should see "You are going to:"
    And I should see the restaurant name
    And I should see the restaurant image
    And I should see the restaurant rating with stars
    And I should see the restaurant address
    And I should see the price range indicator
    And I should see cuisine tags
    And I should see restaurant status "Open" or "Closed"
    And I should see closing time
    And I should see distance "10 min by car"
    And I should see review count link

  Scenario: Guest user does not see feedback option
    Given I am not logged in
    And I am viewing a restaurant result
    Then I should not see "How was it?" section
    And I should not see feedback buttons

  Scenario: Restaurant service returns no results
    Given I am on the solo spin page
    When I fill in preferences with very specific criteria that match no restaurants
    And I click "Spin"
    Then I should see "No restaurants found matching your criteria"
    And I should see "Try adjusting your preferences"

  Scenario: User navigates back to home page
    Given I am on the solo spin page
    When I click on "RESTAURANT ROULETTE" logo
    Then I should be redirected to the home page
