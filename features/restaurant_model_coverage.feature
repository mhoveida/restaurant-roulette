Feature: Restaurant Model Functionality
  As a system
  I want to test restaurant model methods and validations
  So that the Restaurant model has complete test coverage

  Background:
    Given the restaurant database has test data

  Scenario: Display cuisine list as comma-separated string
    Given a restaurant with categories: ["Italian", "Mediterranean", "Wine Bars"]
    When I request the cuisine list
    Then the cuisine list should be "Italian, Mediterranean, Wine Bars"

  Scenario: Handle restaurant with empty categories array
    Given a restaurant with empty categories array
    When I request the cuisine list
    Then the cuisine list should be empty

  Scenario: Handle restaurant with non-array categories
    Given a restaurant with invalid categories type
    When I request the cuisine list
    Then the cuisine list should be empty

  Scenario: Check if restaurant has specific cuisine - match found
    Given a restaurant with categories: ["Italian", "Mediterranean"]
    When I check if the restaurant has cuisine "Italian"
    Then the has_cuisine result should be true

  Scenario: Check if restaurant has specific cuisine - case insensitive
    Given a restaurant with categories: ["Italian", "Mediterranean"]
    When I check if the restaurant has cuisine "italian"
    Then the has_cuisine result should be true

  Scenario: Check if restaurant has specific cuisine - partial match
    Given a restaurant with categories: ["Italian"]
    When I check if the restaurant has cuisine "Ital"
    Then the has_cuisine result should be true

  Scenario: Check if restaurant has specific cuisine - no match
    Given a restaurant with categories: ["Italian", "Mediterranean"]
    When I check if the restaurant has cuisine "Mexican"
    Then the has_cuisine result should be false

  Scenario: Check cuisine with non-array categories
    Given a restaurant with invalid categories type
    When I check if the restaurant has cuisine "Italian"
    Then the has_cuisine result should be false

  Scenario: Filter restaurants that are currently open
    Given there are 5 open restaurants and 3 closed restaurants
    When I query for open restaurants only
    Then the open_now scope should return exactly 5 restaurants
    And all returned restaurants should have is_open_now as true

  Scenario: Open now scope returns empty when all restaurants are closed
    Given all restaurants are closed
    When I query for open restaurants only
    Then the open_now scope should return 0 restaurants

  Scenario: Create restaurant with valid attributes
    When I create a restaurant with valid attributes
    Then the restaurant should be saved successfully

  Scenario: Validation fails when name is missing
    When I create a restaurant without a name
    Then the restaurant should not be saved
    And I should see error "Name can't be blank"

  Scenario: Validation fails when rating is missing
    When I create a restaurant without a rating
    Then the restaurant should not be saved
    And I should see error "Rating can't be blank"

  Scenario: Validation fails when rating is below 0
    When I create a restaurant with rating "-1"
    Then the restaurant should not be saved
    And I should see error "Rating must be greater than or equal to 0"

  Scenario: Validation fails when rating is above 5
    When I create a restaurant with rating "6"
    Then the restaurant should not be saved
    And I should see error "Rating must be less than or equal to 5"

  Scenario: Validation fails when price is missing
    When I create a restaurant without a price
    Then the restaurant should not be saved
    And I should see error "Price can't be blank"

  Scenario: Validation fails when price is invalid
    When I create a restaurant with price "$$$$$"
    Then the restaurant should not be saved
    And I should see error "Price is not included in the list"

  Scenario: Validation allows valid price values
    When I create restaurants with prices "$", "$$", "$$$", "$$$$"
    Then all restaurants should be saved successfully

  Scenario: Validation fails when address is missing
    When I create a restaurant without an address
    Then the restaurant should not be saved
    And I should see error "Address can't be blank"

  Scenario: by_cuisine scope handles empty string
    When I search by cuisine with empty string
    Then the scope should return all restaurants

  Scenario: by_cuisine scope handles nil value
    When I search by cuisine with nil value
    Then the scope should return all restaurants

  Scenario: by_price scope handles empty string
    When I search by price with empty string
    Then the scope should return all restaurants

  Scenario: by_price scope handles nil value
    When I search by price with nil value
    Then the scope should return all restaurants
