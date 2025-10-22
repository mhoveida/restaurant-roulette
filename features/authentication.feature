Feature: User Authentication
  As a visitor
  I want to sign up and log in
  So that I can save my history and get personalized recommendations

  Scenario: Visitor accesses login page from home
    Given I am on the home page
    And I am not logged in
    When I click "Log In" button
    Then I should be redirected to the login page
    And I should see the login form

  Scenario: Login page displays correctly
    Given I am on the login page
    Then I should see "Sign up" tab
    And I should see "Log in" tab
    And the "Log in" tab should be active by default
    And I should see "Log in" heading
    And I should see email input field
    And I should see password input field
    And I should see "Log In" button
    And I should see "Log in with Facebook" button
    And I should see "Log in with Google" button
    And I should see "OR" divider

  Scenario: User logs in with valid email and password
    Given I am on the login page
    When I fill in "Email address" with "maddison@example.com"
    And I fill in "Password" with "SecurePass123"
    And I click "Log In"
    Then I should be logged in as "Maddison"
    And I should be redirected to the home page
    And I should see my name "Maddison" in the profile section

  Scenario: User logs in with invalid credentials
    Given I am on the login page
    When I fill in "Email address" with "maddison@example.com"
    And I fill in "Password" with "WrongPassword"
    And I click "Log In"
    Then I should see "Invalid email or password"
    And I should remain on the login page

  Scenario: User logs in with non-existent email
    Given I am on the login page
    When I fill in "Email address" with "nonexistent@example.com"
    And I fill in "Password" with "password123"
    And I click "Log In"
    Then I should see "Invalid email or password"

  Scenario: User attempts login with empty fields
    Given I am on the login page
    When I click "Log In" without filling any fields
    Then I should see "Please fill in all required fields"

  Scenario: User attempts login with empty email
    Given I am on the login page
    When I fill in "Password" with "password123"
    And I click "Log In"
    Then I should see "Email is required"

  Scenario: User attempts login with empty password
    Given I am on the login page
    When I fill in "Email address" with "maddison@example.com"
    And I click "Log In"
    Then I should see "Password is required"

  Scenario: User logs in with Facebook
    Given I am on the login page
    When I click "Log in with Facebook"
    Then I should be redirected to Facebook authentication
    And after successful Facebook authentication
    Then I should be logged in
    And I should be redirected to the home page

  Scenario: User logs in with Google
    Given I am on the login page
    When I click "Log in with Google"
    Then I should be redirected to Google authentication
    And after successful Google authentication
    Then I should be logged in
    And I should be redirected to the home page

  Scenario: User cancels social media login
    Given I am on the login page
    When I click "Log in with Google"
    And I cancel the Google authentication
    Then I should be returned to the login page
    And I should not be logged in

  Scenario: Social media authentication fails
    Given I am on the login page
    When I click "Log in with Facebook"
    And Facebook authentication fails
    Then I should see "Unable to log in with Facebook. Please try again"
    And I should remain on the login page

  Scenario: User switches to sign up tab
    Given I am on the login page
    When I click "Sign up" tab
    Then the sign up form should be displayed
    And the "Sign up" tab should be active

  # Sign Up Feature Scenarios

  Scenario: Sign up page displays correctly
    Given I am on the login page
    When I click "Sign up" tab
    Then I should see "Sign up" heading
    And I should see "First name" input field
    And I should see "Last name" input field
    And I should see "Email address" input field
    And I should see "Password" input field
    And I should see "Sign Up" button
    And I should see "Sign up with Facebook" button
    And I should see "Sign up with Google" button
    And I should see "OR" divider

  Scenario: User signs up with valid information
    Given I am on the login page
    And I have clicked "Sign up" tab
    When I fill in "First name" with "Olivia"
    And I fill in "Last name" with "Caulfield"
    And I fill in "Email address" with "olivia@example.com"
    And I fill in "Password" with "SecurePass123"
    And I click "Sign Up"
    Then a new account should be created
    And I should be logged in as "Olivia Caulfield"
    And I should be redirected to the home page
    And I should see "Welcome, Olivia!"

  Scenario: User signs up with existing email
    Given an account exists with email "maddison@example.com"
    And I am on the sign up page
    When I fill in "First name" with "Madison"
    And I fill in "Last name" with "Hoveida"
    And I fill in "Email address" with "maddison@example.com"
    And I fill in "Password" with "password123"
    And I click "Sign Up"
    Then I should see "An account with this email already exists"
    And I should remain on the sign up page

  Scenario: User signs up with invalid email format
    Given I am on the sign up page
    When I fill in "First name" with "Ben"
    And I fill in "Last name" with "Benscher"
    And I fill in "Email address" with "invalidemail"
    And I fill in "Password" with "password123"
    And I click "Sign Up"
    Then I should see "Please enter a valid email address"

  Scenario: User signs up with weak password
    Given I am on the sign up page
    When I fill in "First name" with "Ben"
    And I fill in "Last name" with "Benscher"
    And I fill in "Email address" with "ben@example.com"
    And I fill in "Password" with "123"
    And I click "Sign Up"
    Then I should see "Password must be at least 8 characters"

  Scenario: User signs up without first name
    Given I am on the sign up page
    When I fill in "Last name" with "Benscher"
    And I fill in "Email address" with "ben@example.com"
    And I fill in "Password" with "SecurePass123"
    And I click "Sign Up"
    Then I should see "First name is required"

  Scenario: User signs up without last name
    Given I am on the sign up page
    When I fill in "First name" with "Ben"
    And I fill in "Email address" with "ben@example.com"
    And I fill in "Password" with "SecurePass123"
    And I click "Sign Up"
    Then I should see "Last name is required"

  Scenario: User signs up with all empty fields
    Given I am on the sign up page
    When I click "Sign Up" without filling any fields
    Then I should see "Please fill in all required fields"

  Scenario: User signs up with Facebook
    Given I am on the sign up page
    When I click "Sign up with Facebook"
    Then I should be redirected to Facebook authentication
    And after successful Facebook authentication
    Then a new account should be created
    And I should be logged in
    And I should be redirected to the home page

  Scenario: User signs up with Google
    Given I am on the sign up page
    When I click "Sign up with Google"
    Then I should be redirected to Google authentication
    And after successful Google authentication
    Then a new account should be created
    And I should be logged in
    And I should be redirected to the home page

  Scenario: Social sign up with existing account
    Given an account exists linked to Google account "celine@gmail.com"
    And I am on the sign up page
    When I click "Sign up with Google"
    And I authenticate with Google account "celine@gmail.com"
    Then I should be logged into the existing account
    And I should see "Welcome back, Celine!"

  Scenario: Password visibility toggle
    Given I am on the login page
    And the password field is displayed
    Then I should see a password visibility toggle icon
    When I click the toggle icon
    Then the password should be visible as plain text
    When I click the toggle icon again
    Then the password should be hidden

  Scenario: User switches from sign up back to login
    Given I am on the sign up page
    When I click "Log in" tab
    Then the login form should be displayed
    And the "Log in" tab should be active
    And any entered sign up data should be cleared

  Scenario: Session persists across page navigation
    Given I am logged in as "Maddison"
    And I am on the home page
    When I navigate to "Solo Spin" page
    Then I should still be logged in
    And I should see my name "Maddison" in the profile

  Scenario: Email validation on sign up
    Given I am on the sign up page
    When I enter an email in incorrect format
    Then I should see real-time validation error
    And the "Sign Up" button should be disabled

  Scenario: Logout functionality
    Given I am logged in as "Maddison"
    When I click on my profile icon
    And I click "Log Out"
    Then I should be logged out
    And I should be redirected to the home page
    And I should see "Log In" button instead of my name
