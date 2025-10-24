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
  expect(page).to have_css('form', text: /Log in|login/i)
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
  # Check if the tab is active based on current page
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

# User Login Steps
When('I fill in {string} with {string}') do |field, value|
  fill_in field, with: value
end

When('I click {string}') do |button_text|
  click_button button_text
end

When('I click {string} without filling any fields') do |button_text|
  click_button button_text
end

Then('I should be redirected to the login page') do
  expect(page).to have_current_path(new_user_session_path)
end

Then('I should be logged in as {string}') do |name|
  # Verify user is logged in and name appears somewhere on the page
  expect(page).not_to have_button('Log In')
  expect(page).to have_text(name)
end

Then('I should be logged in') do
  expect(page).not_to have_button('Log In')
end

Then('I should not be logged in') do
  expect(page).to have_button('Log In')
end

Then('I should be logged into the existing account') do
  expect(page).not_to have_button('Log In')
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

# User Signup Steps
Given('an account exists with email {string}') do |email|
  create(:user, email: email, first_name: 'Existing', last_name: 'User')
end

Then('a new account should be created') do
  # This is verified by successful login in the next steps
  expect(page).to have_current_path(root_path)
end

# Social Auth Steps
When('I click {string} button') do |button_text|
  click_button button_text
end

Then('I should be redirected to Facebook authentication') do
  # In a real test environment, this would redirect to Facebook's login page
  # For now, we just verify the action was initiated
  # This would be handled by an OAuth library in production
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

# Password visibility
Then('the password field is displayed') do
  expect(page).to have_field('Password', type: 'password')
end

Then('I should see a password visibility toggle icon') do
  # Assuming there's an icon or button that toggles password visibility
  expect(page).to have_css('[data-action*="toggle"], .password-toggle, [aria-label*="show"]', visible: :all)
end

When('I click the toggle icon') do
  # Click the password visibility toggle
  toggle = find('[data-action*="toggle"], .password-toggle, [aria-label*="show"]', visible: :all)
  toggle.click
end

When('I click the toggle icon again') do
  toggle = find('[data-action*="toggle"], .password-toggle, [aria-label*="show"]', visible: :all)
  toggle.click
end

Then('the password should be visible as plain text') do
  password_field = find('input[type="text"]', visible: :all)
  expect(password_field).to be_visible
end

Then('the password should be hidden') do
  password_field = find('input[type="password"]', visible: :all)
  expect(password_field).to be_visible
end

# Error messages
Then('I should see {string}') do |text|
  expect(page).to have_text(text)
end

# Navigation from home page
When('I click {string} button') do |button_text|
  click_button button_text
end
