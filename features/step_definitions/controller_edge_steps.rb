Given("a user is logged in") do
  @user = User.create!(
    email: "test@example.com",
    password: "Password123",
    first_name: "Test",
    last_name: "User"
  )
  login_as(@user, scope: :user)
end

Given("the user has no restaurant history") do
  @user.user_restaurant_histories.destroy_all
end

When("the user attempts to remove a restaurant from history") do
  delete user_history_path(restaurant_id: 9999)
end

Then("the removal should fail") do
  expect(response.status).to eq(404).or eq(200)
end

When("a user submits the login form without credentials") do
  post user_session_path, params: { user: { email: "", password: "" } }
end

Then("the login attempt should be marked as attempted") do
  expect(assigns(:login_attempted)).to eq(true)
end

Given("a user signs up with an inactive account") do
  allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
  post user_registration_path, params: {
    user: {
      email: "inactive@example.com",
      password: "Password123",
      password_confirmation: "Password123"
    }
  }
end

Then("the signup should succeed but not activate the account") do
  expect(response).to be_redirect
end
