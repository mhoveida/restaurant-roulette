module AuthenticationHelpers
  def login_as(user)
    # Use Warden's helper to log in a user during tests
    # This is much faster than visiting the login page
    super(user, scope: :user)
  end
end

World(AuthenticationHelpers)