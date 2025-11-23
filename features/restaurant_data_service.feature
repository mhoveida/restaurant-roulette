Feature: Restaurant Data Service
  As a system
  I want to provide restaurant data from the curated dataset
  So that users can get restaurant recommendations based on their preferences

  Background:
    Given the restaurant service is available

  Scenario: Fetch restaurants based on location and cuisine
    Given a user has selected:
      | Location | Cuisine | Price Range |
      | New York | Italian | $$         |
    When the system requests restaurants
    Then the system should return Italian restaurants
    And each restaurant should include:
      | name        |
      | rating      |
      | price       |
      | address     |
      | phone       |
      | image_url   |
      | categories  |
      | coordinates |

  Scenario: Fetch restaurants with multiple cuisines
    Given a user has selected multiple cuisines: "Italian, American, Mediterranean"
    And location is "New York"
    And price range is "$$"
    When the system requests restaurants
    Then the system should return restaurants matching any of the cuisines
    And restaurants should include Italian, American, and Mediterranean options

  Scenario: Service returns restaurant business hours
    Given a restaurant is fetched from the service
    When the system retrieves restaurant information
    Then the response should include:
      | Field          | Example              |
      | is_open_now    | true/false          |
      | closing_time   | "10:00 PM"          |

  Scenario: Service returns restaurant images
    Given a restaurant is fetched from the service
    When the system requests restaurant details
    Then the response should include an image_url
    And images should be in usable format

  Scenario: Filter by price range
    Given location is "New York"
    And cuisine is "Italian"
    When a user selects "$" price range
    Then the service should return only restaurants with $ pricing
    When a user selects "$$" price range
    Then the service should return only restaurants with $$ pricing

  Scenario: Service returns appropriate number of results
    Given user location is "New York"
    When the system requests restaurants
    Then the service should return available restaurants
    And restaurants should be from the curated dataset

  Scenario: No restaurants found for specific criteria
    Given location is "New York"
    And cuisine is "Ethiopian"
    And price range is "$$$$"
    When the system requests restaurants
    Then the system should return an empty result set
    And the system should display "No restaurants found"
    And should suggest adjusting search criteria

  Scenario: Fetch restaurant reviews count
    Given a restaurant is fetched from the service
    Then the response should include "review_count"
    And review count should be displayed as "(453 review)"

  Scenario: Fetch restaurant categories/tags
    Given a restaurant is fetched from the service
    Then the response should include categories array
    And categories should include cuisine types
    And categories should be displayed as tags like "American, Wine Bars, Cocktail Bars"

  Scenario: Service provides complete restaurant data
    Given a restaurant "Juliana's Pizza" is fetched
    Then the restaurant should have:
      | Field         | Value                               |
      | name          | Juliana's Pizza                     |
      | rating        | 4.7                                 |
      | price         | $$                                  |
      | address       | 19 Old Fulton St, Brooklyn, NY 11201|
      | categories    | Italian                             |
      | is_open_now   | true                                |

  Scenario: Fetch restaurant phone number
    Given a restaurant is fetched from the service
    Then the response should include "phone"
    And phone number should be in formatted display format

  Scenario: Service filters closed restaurants
    Given the service has restaurant data
    When a restaurant has "is_open_now": false
    Then the restaurant should display "Closed" status
    And should not show closing time

  Scenario: Handle multiple price ranges in query
    Given the service has restaurants
    When user selects "$$" price range
    Then only $$ restaurants should be returned
    And $ or $$$ restaurants should be filtered out

  Scenario: Fetch unique restaurants for group room
    Given a room owner has set preferences:
      | Location | Cuisine                        | Price  |
      | New York | Italian, American, Mediterranean | $$    |
    When the owner spins the wheel 3 times
    Then each spin should return a unique restaurant
    And no restaurant should be repeated in the same room
    And all restaurants should match the criteria

  Scenario: Parse restaurant address correctly
    Given restaurant "Katz's Delicatessen" is fetched
    Then the address should be formatted as "205 E Houston St, New York, NY 10002"
    And should include street, city, state, and zip code

  Scenario: Service removes duplicate restaurants
    Given the service has restaurant data
    When the system processes results
    Then each restaurant should appear only once
    And duplicates should be automatically filtered

  Scenario: Handle restaurants with missing images
    Given a restaurant without an image is requested
    When the system displays the restaurant
    Then a default placeholder image should be used
    And the restaurant should still be displayed with all other information

  Scenario: Service provides consistent data format
    Given multiple restaurants are fetched
    When the system receives the data
    Then all restaurants should have the same data structure
    And all required fields should be present
    And data types should be consistent across all restaurants

  Scenario: Filter restaurants by multiple criteria
    Given location is "New York"
    And cuisine is "Mexican"
    And price range is "$$"
    When the system requests restaurants
    Then the service should return only restaurants matching all three criteria
    And should return "Toloache" as a match

  Scenario: Service returns realistic restaurant data
    Given restaurants are fetched from the service
    Then all restaurants should have:
      | ratings between 3.5 and 5.0    |
      | valid NYC addresses            |
      | realistic review counts        |
      | appropriate cuisine categories |
      | valid phone numbers           |

  Scenario: Get random restaurant for solo spin
    Given location is "New York"
    And cuisine is "Italian"
    And price range is "$$"
    When a user spins the wheel
    Then the service should return one random matching restaurant
    And the restaurant should meet all specified criteria

  Scenario: Data includes all prototype restaurants
    Given the restaurant service is available
    When all restaurants are fetched
    Then the dataset should include "Balthazar"
    And should include "Lilia"
    And should include "Katz's Delicatessen"
    And should include at least 20 restaurants total
