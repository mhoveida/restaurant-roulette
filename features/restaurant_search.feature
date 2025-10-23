
Feature: Restaurant Search
  As a user
  I want to search for restaurants
  So I can find places to eat

  Background:
    Given the restaurant service is available

  Scenario: Search for Italian restaurants
    When I search for "Italian" restaurants in "New York"
    Then I should see at least 3 restaurants
    And I should see "Da Andrea" in the results
    And I should see "Carbone" in the results

  Scenario: Search by price range
    When I search for restaurants with price "$" in "New York"
    Then I should see at least 2 restaurants
    And I should see "Shake Shack" in the results
    And I should see "Prince Street Pizza" in the results

  Scenario: Search for Japanese restaurants
    When I search for "Japanese" restaurants in "New York"
    Then I should see at least 2 restaurants
    And I should see "Ippudo NY" in the results