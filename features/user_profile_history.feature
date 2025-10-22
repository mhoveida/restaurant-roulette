Feature: User Profile and History
  As a logged in user
  I want to view and manage my profile and dining history
  So that I can get personalized recommendations and track my restaurant experiences

  Background:
    Given I am logged in as "Celine"

  Scenario: User accesses profile from navigation
    Given I am on the home page
    When I click on the user profile icon showing "Celine"
    Then I should see a profile dropdown menu
    And I should see "View History" option
    And I should see "Log Out" option

  Scenario: User views dining history
    Given I have previously visited restaurants after spinning
    When I click on the profile icon
    And I click "View History"
    Then I should be on the history page
    And I should see a list of restaurants I've visited
    And each entry should show:
      | Restaurant name |
      | My rating       |
      | Cuisine type    |
      | Price range     |


  Scenario: User filters history by rating
    Given I am on the history page
    When I filter by "Liked" restaurants
    Then I should only see restaurants I gave thumbs up to

  Scenario: User views detailed history entry
    Given I am on the history page
    When I click on a restaurant entry "Da Andrea"
    Then I should see detailed information:
      | Field              | Value                            |
      | Restaurant name    | Da Andrea                        |
      | My feedback        | Thumbs up                        |
      | Spin type          | Solo Spin                        |
      | Selected cuisines  | Italian, Mediterranean           |
      | Price range used   | $$                               |
      | Location used      | New York                         |

  Scenario: Empty history for new user
    Given I am a new user
    And I have not completed any spins yet
    When I view my history
    Then I should see "No dining history yet"
    And I should see "Start spinning to discover restaurants!"
    And I should see a "Start Spinning" button

  Scenario: Personalized recommendations based on history
    Given I have a dining history with preferences
    And I have liked Italian restaurants 5 times
    And I have liked $$ price range restaurants
    When I go to solo spin page
    Then Italian cuisine should be suggested
    And $$ price range should be pre-selected
    And I should see "Based on your history" hint

  Scenario: Recommendation adapts to recent feedback
    Given I have historically liked Italian restaurants
    But I recently gave thumbs down to 3 Italian restaurants
    When I view recommendations
    Then Italian should appear less frequently in suggestions
    And other cuisines I've liked should be prioritized

  Scenario: History includes both solo and group spins
    Given I have done both solo spins and group spins
    When I view my history
    Then each entry should be labeled "Solo Spin" or "Group Spin"
    And group spin entries should show room code
    And group spin entries should show other participants

  Scenario: User views group spin history details
    Given I am viewing a group spin history entry
    Then I should see the room code
    And I should see list of participants
    And I should see all restaurant options that were voted on
    And I should see which restaurant won the vote
    And I should see how I voted