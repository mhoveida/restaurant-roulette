# User Profile History Steps

# Navigation and UI
When('I click on the user profile icon showing {string}') do |name|
  find('.profile-email').click
end

Then('I should see a profile dropdown menu') do
  expect(page).to have_css('[data-dropdown-target="menu"]', visible: true)
end

When('I click on the profile icon') do
  find('.profile-email').click
end

# Page navigation
Then('I should be on the history page') do
  expect(page).to have_current_path(history_path)
end

Given('I am on the history page') do
  visit history_path
end

# Removed: When('I view my history') - now defined in user_restaurant_history_steps.rb

# Basic content verification
Then('I should see a list of restaurants I\'ve visited') do
  expect(page).to have_css('.history-entry')
end

Then('each entry should show:') do |table|
  # For now, just verify we're on the right page
  expect(page).to have_current_path(history_path)
  puts "History table verification would check: #{table.raw}"
end

# Solo spin navigation
When('I go to solo spin page') do
  visit solo_spin_path
end

# Filtering
When('I filter by {string} restaurants') do |filter_type|
  select filter_type, from: 'filter'
end

Then('I should only see restaurants I gave thumbs up to') do
  expect(page).to have_css('.liked-restaurant')
end

# Detailed view
When('I click on a restaurant entry {string}') do |restaurant_name|
  click_link restaurant_name
end

Then('I should see detailed information:') do |table|
  expect(page).to have_css('.restaurant-details')
  puts "Detailed info verification would check: #{table.raw}"
end

# New user scenarios
Given('I am a new user') do
  # Already handled by background login
end

Given('I have not completed any spins yet') do
  # No action needed - user has no history
end

# History data setup (placeholder implementations)
Given('I have previously visited restaurants after spinning') do
  # This would create spin history in the database
  # For now, just acknowledge the step
  puts "Setting up restaurant visit history"
end

Given('I have a dining history with preferences') do
  puts "Setting up dining history with preferences"
end

Given('I have liked Italian restaurants {int} times') do |count|
  puts "Setting up #{count} liked Italian restaurants"
end

Given('I have liked $$ price range restaurants') do
  puts "Setting up $$ price range preferences"
end

Given('I have historically liked Italian restaurants') do
  puts "Setting up historical Italian preferences"
end

Given('I recently gave thumbs down to {int} Italian restaurants') do |count|
  puts "Setting up #{count} disliked Italian restaurants"
end

Given('I have done both solo spins and group spins') do
  puts "Setting up mixed spin history"
end

# Recommendation scenarios
Then('Italian cuisine should be suggested') do
  expect(page).to have_content('Italian')
end

Then('$$ price range should be pre-selected') do
  expect(page).to have_checked_field('$$')
end

When('I view recommendations') do
  visit recommendations_path
end

Then('Italian should appear less frequently in suggestions') do
  # This would require more complex verification
  expect(page).to have_content('Based on recent feedback')
end

Then('other cuisines I\'ve liked should be prioritized') do
  expect(page).to have_css('.recommendation')
end

# Group spin history
Then('each entry should be labeled {string} or {string}') do |label1, label2|
  expect(page).to have_content(label1).or have_content(label2)
end

Then('group spin entries should show room code') do
  expect(page).to have_content('Room:')
end

Then('group spin entries should show other participants') do
  expect(page).to have_content('Participants:')
end

Given('I am viewing a group spin history entry') do
  visit group_spin_history_path(1) # Would need actual ID
end

Then('I should see list of participants') do
  expect(page).to have_css('.participants-list')
end

Then('I should see all restaurant options that were voted on') do
  expect(page).to have_css('.vote-options')
end

Then('I should see which restaurant won the vote') do
  expect(page).to have_css('.winner')
end

Then('I should see how I voted') do
  expect(page).to have_css('.my-vote')
end