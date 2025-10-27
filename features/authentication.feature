Feature: User Authentication
  As a visitor
  I want to sign up and log in
  So that I can save my history and get personalized recommendations

  Scenario: Visitor accesses login page from home
    Given I am on the home page
    And I am not logged in
    When I click "Log In"
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

  Scenario: User can remain logged in across page navigation
    Given I am logged in as "Maddison Test"
    And I am on the home page
    Then I should still be logged in
    And I should see my name "Maddison Test" in the profile

  Scenario: User is logged out by default
    Given I am on the login page
    Then I should not be logged in
    And I should see "Log In" button

  Scenario: User can see profile information when logged in
    Given I am logged in as "Sarah Johnson"
    When I am on the home page
    Then I should see my name "Sarah Johnson" in the profile
    And I should see my name "Sarah" in the profile section
    And I should still be logged in

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
    When I have clicked "Sign up" tab
    Then the sign up form should be displayed
    And the "Sign up" tab should be active

  # Login Form Validation Scenarios

  Scenario: User attempts login with empty email field
    Given I am on the login page
    When I fill in "Password" with "SomePassword123"
    And I click "Log In"
    Then I should be on the login page
    And I should see "Email address" input field

  Scenario: User attempts login with empty password field
    Given I am on the login page
    When I fill in "Email address" with "user@example.com"
    And I click "Log In"
    Then I should be on the login page
    And I should see "Password" input field

  Scenario: User attempts login with both fields empty
    Given I am on the login page
    When I click "Log In"
    Then I should be on the login page
    And I should see "Email address" input field

  Scenario: User logs in with wrong password
    Given an account exists with email "test@example.com" and password "CorrectPassword123"
    And I am on the login page
    When I fill in "Email address" with "test@example.com"
    And I fill in "Password" with "WrongPassword123"
    And I click "Log In"
    Then I should be on the login page

  Scenario: User logs in with non-existent email
    Given I am on the login page
    When I fill in "Email address" with "nonexistent@example.com"
    And I fill in "Password" with "SomePassword123"
    And I click "Log In"
    Then I should be on the login page

  # Sign Up Form Validation Scenarios

  Scenario: User signs up without first name
    Given I am on the sign up page
    When I fill in "Last name" with "Doe"
    And I fill in "Email address" with "john@example.com"
    And I fill in "Password" with "ValidPassword123"
    And I click "Sign Up"
    Then I should be on the sign up page

  Scenario: User signs up without last name
    Given I am on the sign up page
    When I fill in "First name" with "John"
    And I fill in "Email address" with "john@example.com"
    And I fill in "Password" with "ValidPassword123"
    And I click "Sign Up"
    Then I should be on the sign up page

  Scenario: User signs up without email
    Given I am on the sign up page
    When I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I fill in "Password" with "ValidPassword123"
    And I click "Sign Up"
    Then I should be on the sign up page

  Scenario: User signs up without password
    Given I am on the sign up page
    When I fill in "First name" with "John"
    And I fill in "Last name" with "Doe"
    And I fill in "Email address" with "john@example.com"
    And I click "Sign Up"
    Then I should be on the sign up page

  Scenario: User signs up with all fields empty
    Given I am on the sign up page
    When I click "Sign Up"
    Then I should be on the sign up page

  Scenario: User signs up with existing email
    Given an account exists with email "existing@example.com"
    And I am on the sign up page
    When I fill in "First name" with "Jane"
    And I fill in "Last name" with "Doe"
    And I fill in "Email address" with "existing@example.com"
    And I fill in "Password" with "ValidPassword123"
    And I click "Sign Up"
    Then I should be on the sign up page

  # Sign Up Feature Scenarios

  Scenario: Sign up page displays correctly
    Given I am on the sign up page
    Then I should see "Sign Up" heading
    And I should see "First name" input field
    And I should see "Last name" input field
    And I should see "Email address" input field
    And I should see "Password" input field
    And I should see "Sign Up" button

  Scenario: Sign up form shows all required fields
    Given I am on the sign up page
    Then I should see "First name" input field
    And I should see "Last name" input field
    And I should see "Email address" input field
    And I should see "Password" input field
    And I should see "Sign Up" button

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
    When I have clicked "Log in" tab
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
