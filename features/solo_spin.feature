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
    And I should see "Set Your Preferences"
    And I should see "Choose your criteria for the perfect restaurant"
    And I should see a "Name" input field
    And I should see a "Neighborhood" dropdown
    And I should see a "Price Range" dropdown
    And I should see the cuisine selection grid

  Scenario: Logged in user sees pre-filled name
    Given I am logged in as "Maddison"
    When I visit the solo spin page
    Then the "Name" field should contain "Maddison"
    And the "Name" field should be read-only

  @javascript
  Scenario: User sees validation error when fields are empty
    Given I am on the solo spin page
    When I click "Spin the Wheel!"
    Then I should see a validation message "Please fill in all fields"
    And the wheel should not be spinning

  @javascript
  Scenario: User spins the wheel with exact match
    Given I am on the solo spin page
    When I fill in "Your Name" with "Guest User"
    And I select "SoHo" from the "Neighborhood" dropdown
    And I select "$$$ - Upscale" from the "Price Range" dropdown
    And I select "French" from the cuisine grid
    And I click "Spin the Wheel!"
    Then the wheel should spin
    And I should see the result modal
    And I should see "🎉 You should try:"
    And I should see the restaurant name "Balthazar"
    And I should see the star rating
    And I should see the price "$$$"
    And I should see the address "80 Spring St"
    And I should see a "View on Map" button

  @javascript
  Scenario: User spins and gets a fuzzy match (Fallback logic)
    Given I am on the solo spin page
    And the database has limited restaurants
    When I fill in "Your Name" with "Guest User"
    And I select "SoHo" from the "Neighborhood" dropdown
    # Selecting a combination that might not exist exactly, triggering fallback
    And I select "$$ - Moderate" from the "Price Range" dropdown 
    And I select "Korean" from the cuisine grid
    And I click "Spin the Wheel!"
    Then I should see the result modal
    And I should see the restaurant name
    # Checks for the match type text defined in your JS getMatchTypeText()
    And I should see text indicating a partial match like "Same area" or "Random pick"

  @javascript
  Scenario: User shares the result
    Given I have spun the wheel and see a result
    When I click the "Share" button
    Then the share button text should change to "✓ Copied!"

  Scenario: User navigates back to home
    Given I am on the solo spin page
    When I click "← Back to Home"
    Then I should be on the home page