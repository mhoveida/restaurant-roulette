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
  expect(page).to have_field('Email address', type: 'email', visible: :all)
end

Then('I should see password input field') do
  expect(page).to have_field('Password', type: 'password', visible: :all)
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
# (Using generic web_steps "I click" definition)

# Login results
Then('I should be on the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('I should be on the sign up page') do
  expect(page).to have_current_path(new_user_registration_path)
end

Then('I should be redirected to the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('I should be logged in as {string}') do |name|
  # Wait for the page to load after form submission
  using_wait_time(10) do
    # Check that we're no longer on the login/signup page
    expect(page).not_to have_current_path(new_user_session_path)
    expect(page).not_to have_current_path(new_user_registration_path)
    # Check that the name appears on the page
    expect(page).to have_text(name)
  end
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

# Signup & Account Creation
Given('an account exists with email {string}') do |email|
  create(:user, email: email, first_name: 'Existing', last_name: 'User')
end

Given('an account exists with email {string} and password {string}') do |email, password|
  create(:user, email: email, first_name: 'Test', last_name: 'User', password: password, password_confirmation: password)
end

Given('a user account exists with email {string} and password {string}') do |email, password|
  create(:user, email: email, first_name: 'Test', last_name: 'User', password: password, password_confirmation: password)
end

Given('I am logged in as {string}') do |name|
  # Extract first and last name from the full name
  names = name.split(' ')
  first_name = names[0]
  last_name = names.length > 1 ? names[1..].join(' ') : "User"

  # Create the user directly to avoid Warden mapping issues
  user = User.create!(
    email: "#{first_name.downcase}@example.com",
    first_name: first_name,
    last_name: last_name,
    password: 'TestPassword123',
    password_confirmation: 'TestPassword123',
    confirmed_at: Time.current
  )

  # Log in the user by filling in the login form
  visit new_user_session_path
  # Make sure we're on the login form (click login tab if needed)
  if page.has_css?('[data-auth-form-target="loginTab"]')
    page.find('[data-auth-form-target="loginTab"]').click
  end
  fill_in 'Email address', with: user.email
  fill_in 'Password', with: 'TestPassword123'
  # Click the Log In button in the login form specifically
  within '[data-auth-form-target="loginForm"]' do
    click_button 'Log In'
  end
  # Wait for redirect and ensure we're on home page
  begin
    page.driver.wait_for_network_idle(timeout: 3) if page.driver.respond_to?(:wait_for_network_idle)
  rescue
    sleep(0.5)
  end
  visit root_path unless page.has_content?('RESTAURANT')
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
Then('I should be redirected to Facebook authentication') do
  skip('Facebook OAuth integration not yet implemented')
end

Then('I should be redirected to Google authentication') do
  skip('Google OAuth integration not yet implemented')
end

Then('after successful Facebook authentication') do
  skip('Facebook OAuth integration not yet implemented')
end

Then('after successful Google authentication') do
  skip('Google OAuth integration not yet implemented')
end

When('I cancel the Google authentication') do
  skip('Google OAuth cancellation not yet implemented')
end

When('I authenticate with Google account {string}') do |email|
  skip('Google OAuth authentication not yet implemented')
end

When('Facebook authentication fails') do
  skip('Facebook OAuth error handling not yet implemented')
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
