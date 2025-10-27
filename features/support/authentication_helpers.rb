module AuthenticationHelpers
  def login_as(user, scope: :user)
    # Use Warden's helper to log in a user during tests
    # This is much faster than visiting the login page
    super(user, scope: scope)
  end
end

World(AuthenticationHelpers)
