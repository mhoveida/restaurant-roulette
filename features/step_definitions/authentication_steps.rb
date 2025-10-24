# Authentication Steps

# Navigation
Given('I am on the login page') do
  visit new_user_session_path
end

Given('I am on the sign up page') do
  visit new_user_registration_path
end

# Form Display Steps
Then('I should see the login form') do
  expect(page).to have_css('form')
end

Then('the login form should be displayed') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('the sign up form should be displayed') do
  expect(page).to have_current_path(new_user_registration_path)
end

Then('I should see email input field') do
  expect(page).to have_field('Email address', type: 'email')
end

Then('I should see password input field') do
  expect(page).to have_field('Password', type: 'password')
end

# Tab Navigation
Given('I have clicked {string} tab') do |tab_name|
  case tab_name
  when 'Sign up'
    visit new_user_registration_path
  when 'Log in'
    visit new_user_session_path
  end
end

Then('the {string} tab should be active by default') do |tab_name|
  if tab_name == 'Log in'
    expect(page).to have_current_path(new_user_session_path)
  elsif tab_name == 'Sign up'
    expect(page).to have_current_path(new_user_registration_path)
  end
end

Then('the {string} tab should be active') do |tab_name|
  if tab_name == 'Log in'
    expect(page).to have_current_path(new_user_session_path)
  elsif tab_name == 'Sign up'
    expect(page).to have_current_path(new_user_registration_path)
  end
end

# Form filling and submission
When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string} without filling any fields') do |button_text|
  click_button button_text
end

# Login results
Then('I should be redirected to the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('I should be logged in as {string}') do |name|
  expect(page).not_to have_button('Log In')
  expect(page).to have_text(name)
end

Then('I should be logged in') do
  expect(page).not_to have_button('Log In')
end

Then('I should not be logged in') do
  expect(page).to have_button('Log In')
end

Then('I should see my name {string} in the profile section') do |name|
  expect(page).to have_text(name)
end

Then('I should see my name {string} in the profile') do |name|
  expect(page).to have_text(name)
end

Then('I should remain on the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('I should remain on the sign up page') do
  expect(page).to have_current_path(new_user_registration_path)
end

# Signup
Given('an account exists with email {string}') do |email|
  create(:user, email: email, first_name: 'Existing', last_name: 'User')
end

Then('a new account should be created') do
  expect(page).to have_current_path(root_path)
end

Then('I should be logged into the existing account') do
  expect(page).not_to have_button('Log In')
end

# Error messages
# "I should see" is already handled in web_steps.rb

# Password visibility
Then('the password field is displayed') do
  expect(page).to have_field('Password', type: 'password')
end

Then('I should see a password visibility toggle icon') do
  pending('Password visibility toggle not yet implemented')
end

When('I click the toggle icon') do
  pending('Password visibility toggle not yet implemented')
end

When('I click the toggle icon again') do
  pending('Password visibility toggle not yet implemented')
end

Then('the password should be visible as plain text') do
  pending('Password visibility toggle not yet implemented')
end

Then('the password should be hidden') do
  pending('Password visibility toggle not yet implemented')
end

# OAuth - all pending for now
When('I click {string} button') do |button_text|
  click_button button_text
end

Then('I should be redirected to Facebook authentication') do
  pending('Facebook OAuth integration not yet implemented')
end

Then('I should be redirected to Google authentication') do
  pending('Google OAuth integration not yet implemented')
end

Then('after successful Facebook authentication') do
  pending('Facebook OAuth integration not yet implemented')
end

Then('after successful Google authentication') do
  pending('Google OAuth integration not yet implemented')
end

When('I cancel the Google authentication') do
  pending('Google OAuth cancellation not yet implemented')
end

When('I authenticate with Google account {string}') do |email|
  pending('Google OAuth authentication not yet implemented')
end

When('Facebook authentication fails') do
  pending('Facebook OAuth error handling not yet implemented')
end

Given('an account exists linked to Google account {string}') do |email|
  pending('Google OAuth account linking not yet implemented')
end

Then('I should be returned to the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

# Other
When('I click on my profile icon') do
  pending('Profile icon interaction not yet implemented')
end

Then('I should be logged out') do
  expect(page).to have_button('Log In')
end

Then('any entered sign up data should be cleared') do
  # Step would clear form data
  pending('Form clearing not yet tested')
end

Then('I navigate to {string} page') do |page_name|
  pending('Navigation not yet implemented for: ' + page_name)
end

Then('I should still be logged in') do
  expect(page).not_to have_button('Log In')
end

Then('I enter an email in incorrect format') do
  fill_in 'Email address', with: 'invalidemail'
end

Then('I should see real-time validation error') do
  pending('Real-time validation not yet implemented')
end

Then('the {string} button should be disabled') do |button_name|
  pending('Button disable logic not yet implemented')
end
