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

  Scenario: User attempts to spin without filling required fields
    Given I am on the solo spin page
    When I click "Spin" without filling all fields
    Then I should see "Please fill in all required fields"
    And the wheel should not spin

  Scenario: User searches for location with suggestions
    Given I am on the solo spin page
    When I click on the location field
    And I type "New Y"
    Then I should see location suggestions
    And I should see "New York" in the suggestions

  Scenario: User selects price range options
    Given I am on the solo spin page
    When I click on "Price Range" dropdown
    Then I should see "$" option
    And I should see "$$" option
    And I should see "$$$" option
    And I should see "$$$$" option

  Scenario: User selects multiple cuisine preferences
    Given I am on the solo spin page
    When I click on "Cuisine Preferences" dropdown
    Then I should see a list of cuisine options
    When I select "Italian"
    And I select "American"
    And I select "Mediterranean"
    Then I should see "Italian" as a selected tag with X button
    And I should see "American" as a selected tag with X button
    And I should see "Mediterranean" as a selected tag with X button

  Scenario: User removes a selected cuisine
    Given I am on the solo spin page
    And I have selected cuisines "Italian, American, Mediterranean"
    When I click the X button on "American" tag
    Then "American" should be removed from selected cuisines
    And I should only see "Italian" and "Mediterranean" tags

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

  Scenario: User views detailed restaurant information
    Given I am viewing a restaurant result
    Then I should see the restaurant photo
    And I should see business hours information
    And I should see the full address with map pin icon
    And I should see category tags
    And I should see a share button
    And I should see an upload to app button (iOS share icon)

  Scenario: Logged in user spins again from result page
    Given I am logged in
    And I am viewing a restaurant result
    When I click "Spin again"
    Then the restaurant result should close
    And I should return to the solo spin page
    And my previous preferences should be retained

  Scenario: Guest user spins again
    Given I am not logged in
    And I am viewing a restaurant result
    When I click "Spin again"
    Then I should return to the solo spin page
    And my previous preferences should be cleared

  Scenario: User closes restaurant result
    Given I am viewing a restaurant result
    When I click the X button
    Then the result overlay should close
    And I should return to the solo spin page

  Scenario: Logged in user provides feedback after visit
    Given I am logged in as "Maddison"
    And I am viewing a restaurant result "Bourbon and Branch"
    Then I should see "How was it?"
    And I should see "Help us to learn your preferences"
    And I should see a thumbs down button
    And I should see a thumbs up button

  Scenario: User gives positive feedback
    Given I am logged in
    And I am viewing a restaurant result
    When I click the thumbs up button
    Then the feedback should be recorded
    And I should see "Thank you for your feedback"
    And my preferences should be updated for future recommendations

  Scenario: User gives negative feedback
    Given I am logged in
    And I am viewing a restaurant result
    When I click the thumbs down button
    Then the feedback should be recorded
    And I should see "Thank you for your feedback"
    And this restaurant preference should be noted for future avoidance

  Scenario: Guest user does not see feedback option
    Given I am not logged in
    And I am viewing a restaurant result
    Then I should not see "How was it?" section
    And I should not see feedback buttons

  Scenario: User shares restaurant result
    Given I am viewing a restaurant result
    When I click the share button
    Then I should see share options
    And the shared message should include restaurant name and address

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

  Scenario: Logged in user sees recommendation based on history
    Given I am logged in as "Maddison"
    And I have previously liked Italian restaurants
    And I am on the solo spin page
    When I view the cuisine preferences
    Then "Italian" might be pre-suggested
    And I should see a hint "Based on your history"
