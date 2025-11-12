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
  expect(page).to have_css('[data-auth-form-target="loginForm"]', visible: true)
  expect(page).to have_css('[data-auth-form-target="signupForm"]', visible: false)
end

Then('the sign up form should be displayed') do
  expect(page).to have_css('[data-auth-form-target="signupForm"]', visible: true)
  expect(page).to have_css('[data-auth-form-target="loginForm"]', visible: false)
end

Then('I should see email input field') do
  expect(page).to have_field('Email address', type: 'email', visible: :all)
end

Then('I should see password input field') do
  expect(page).to have_field('Password', type: 'password', visible: :all)
end

# Tab Navigation
Given('I have clicked {string} tab') do |tab_name|
  # Actually click the tab instead of visiting URLs
  case tab_name
  when 'Sign Up'
    find('[data-auth-form-target="signupTab"]').click
  when 'Log In'
    find('[data-auth-form-target="loginTab"]').click
  end

  # Wait for the JavaScript to process
  sleep 0.5
end

Then('the {string} tab should be active by default') do |tab_name|
  case tab_name
  when 'Log In'
    expect(page).to have_css('[data-auth-form-target="loginTab"].active')
    expect(page).to have_css('[data-auth-form-target="signupTab"]:not(.active)')
  when 'Sign Up'
    expect(page).to have_css('[data-auth-form-target="signupTab"].active')
    expect(page).to have_css('[data-auth-form-target="loginTab"]:not(.active)')
  end
end

Then('the {string} tab should be active') do |tab_name|
  case tab_name
  when 'Log In'
    expect(page).to have_css('[data-auth-form-target="loginTab"].active')
    expect(page).to have_css('[data-auth-form-target="signupTab"]:not(.active)')
  when 'Sign Up'
    expect(page).to have_css('[data-auth-form-target="signupTab"].active')
    expect(page).to have_css('[data-auth-form-target="loginTab"]:not(.active)')
  end
end

# Form filling and submission
# (Using generic web_steps "I click" definition)

# Login results
Then('I should be on the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('I should be on the sign up page') do
  expect([ new_user_registration_path, '/users' ]).to include(page.current_path)
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
  expect([ new_user_registration_path, '/users' ]).to include(page.current_path)
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
  expect(page).to have_css('.password-toggle', visible: true)
end

When('I click the toggle icon') do
  find('.password-toggle', match: :first).click
end

When('I click the toggle icon again') do
  find('.password-toggle', match: :first).click
end

Then('the password should be visible as plain text') do
  password_field = find('[data-auth-form-target="loginPassword"], [data-auth-form-target="signupPassword"]', match: :first)
  expect(password_field[:type]).to eq('text')
end

Then('the password should be hidden') do
  password_field = find('[data-auth-form-target="loginPassword"], [data-auth-form-target="signupPassword"]', match: :first)
  expect(password_field[:type]).to eq('password')
end

# OAuth - Google

# Enable OmniAuth test mode for mocking
Before('@google') do
  OmniAuth.config.test_mode = true
end

After('@google') do
  OmniAuth.config.mock_auth[:google_oauth2] = nil
  OmniAuth.config.test_mode = false
end

# Create a user linked to a Google account
Given('an account exists linked to Google account {string}') do |email|
  User.create!(
    email: email,
    first_name: 'Test',
    last_name: 'User',
    password: 'TestPassword123',
    password_confirmation: 'TestPassword123',
    confirmed_at: Time.current,
    provider: 'google_oauth2',
    uid: '123545'
  )
end

# Mock a successful Google OAuth login
When('I authenticate with Google account {string}') do |email|
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: '123545',
    info: {
      email: email,
      first_name: 'Test',
      last_name: 'User'
    },
    credentials: {
      token: 'mock_token',
      refresh_token: 'mock_refresh_token',
      expires_at: Time.now + 1.week
    }
  )
end

# Verify successful Google authentication
Then('after successful Google authentication') do
  using_wait_time 5 do
    expect(page).to have_current_path(root_path)
  end
end

# Verify user is redirected back to login after cancel/failure
Then('I should be returned to the login page') do
  using_wait_time 5 do
    expect(page).to have_current_path(new_user_session_path)
  end
end

# Other
# Verify Profile interaction
When('I click on my profile icon') do
  # Just verify the profile exists - don't actually logout here
  expect(page).to have_css('.profile-email')
end

When('I click the logout link') do
  # Try the logout
  Capybara.current_session.driver.submit :delete, destroy_user_session_path, nil
end

Then('I should be logged out') do
  # Check for either a Log In button OR a Log In link
  has_login_button = page.has_button?('Log In')
  has_login_link = page.has_link?('Log In')

  # Expect either a button OR a link to be present
  expect(has_login_button || has_login_link).to be true
end

Then('any entered sign up data should be cleared') do
  using_wait_time 2 do
    expect(page).to have_field('First name', with: '', visible: :all)
    expect(page).to have_field('Last name', with: '', visible: :all)
    expect(page).to have_field('Email address', with: '', visible: :all)
    expect(page).to have_field('Password', with: '', visible: :all)
  end
end

Then('I navigate to {string} page') do |page_name|
  case page_name.downcase
  when 'solo spin'
    visit solo_spin_path
  when 'home'
    visit root_path
  when 'create room'
    visit create_room_path
  else
    raise "Unknown page: #{page_name}"
  end

  # Wait for the page to load
  expect(page).to have_current_path(send("#{page_name.downcase.gsub(' ', '_')}_path"))
end

Then('I should still be logged in') do
  expect(page).not_to have_button('Log In')
end

Then('I enter an email in incorrect format') do
  fill_in 'Email address', with: 'invalid-email'
end

Then('I should see real-time validation error') do
  # Test actual real-time validation
  expect(page).to have_css('.validation-message', visible: true)
end

Then('the {string} button should be disabled') do |button_name|
  sleep 1

  case button_name
  when "Sign Up"
    button = find('[data-auth-form-target="signupForm"] button[type="submit"]')
  when "Log In"
    button = find('[data-auth-form-target="loginForm"] button[type="submit"]')
  else
    button = find_button(button_name)
  end

  expect(button.disabled?).to be true
end
