Feature: Recommendations and Personalization
  As a logged in user with dining history
  I want to receive personalized restaurant recommendations
  So that the app learns my preferences and suggests better matches over time

  Background:
    Given I am logged in as "Maddison"
    And I have a dining history

  Scenario: System learns from positive feedback
    Given I have given thumbs up to 5 Italian restaurants
    And I have given thumbs up to 3 restaurants in $$ price range
    When I start a new solo spin
    Then Italian cuisine should be pre-suggested
    And $$ price range should be pre-selected
    And I should see "Based on your history" hint

  Scenario: System learns from negative feedback
    Given I have given thumbs down to 3 Chinese restaurants
    When the system generates restaurant options
    Then Chinese restaurants should appear less frequently
    And should be deprioritized in results

  Scenario: Balanced recommendations with mixed feedback
    Given I have liked 5 Italian restaurants
    And I have disliked 2 Italian restaurants
    When I request recommendations
    Then Italian should still be suggested
    But with moderate confidence
    And other cuisines I've liked should also be suggested

  Scenario: New user receives no personalized suggestions
    Given I am a new user with no history
    When I access solo spin page
    Then no cuisine should be pre-selected
    And no price range should be pre-selected
    And I should not see "Based on your history" hint

  Scenario: Recommendations adapt over time
    Given I initially liked Italian restaurants
    But my last 5 visits have been to Japanese restaurants
    And all Japanese restaurants received positive feedback
    When I start a new spin
    Then Japanese should be prioritized in suggestions
    And Italian should be secondary

  Scenario: Price range preference learning
    Given I have visited 10 restaurants
    And 8 of them were in $$ price range
    And I gave positive feedback to 7 of them
    When I start a new solo spin
    Then $$ should be pre-selected as price range
    And restaurants in this price range should be prioritized

  Scenario: Location-based recommendations
    Given I frequently spin in "Brooklyn, NY"
    And I have positive feedback for restaurants there
    When I start a new spin
    Then "Brooklyn, NY" should appear as a suggested location
    And I should see "You frequently search here"

  Scenario: Group preferences don't affect personal recommendations
    Given I participated in a group spin
    And the group chose Mexican restaurant
    But I personally prefer Italian
    When I do a solo spin later
    Then my recommendations should still be based on my individual history
    And the group decision should not heavily influence my personal profile

  Scenario: Incorporate rating preferences
    Given I tend to like restaurants with 4.5+ star ratings
    And I've given thumbs down to restaurants below 4.0
    When recommendations are generated
    Then restaurants with higher ratings should be prioritized
    And lower-rated restaurants should be filtered out

  Scenario: Learn from partial preferences
    Given I always select Italian cuisine
    But I vary my price range selections
    When I start a new spin
    Then Italian should be pre-suggested strongly
    But price range should remain open for my selection

  Scenario: No history override by user choice
    Given the system suggests Italian based on my history
    When I manually select "Japanese" instead
    Then the system should respect my choice
    And should show Japanese restaurants
    And should learn from this deviation