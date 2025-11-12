Before do
  # Clean test state before each scenario
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.start

  # Stub ActionCable test adapter to avoid subscription errors
  ActionCable.server.config.cable = { adapter: "test" }

  # Auto-create a default user for "logged in as"
  @current_user = User.first || FactoryBot.create(:user, email: "maddison@example.com", password: "password", first_name: "Maddison")
end

After do
  DatabaseCleaner.clean
end

# Automatically dismiss JS alerts so tests don't fail with "unexpected alert open"
AfterStep('@javascript') do
  begin
    page.driver.browser.switch_to.alert.accept
  rescue Selenium::WebDriver::Error::NoSuchAlertError
    # ignore if there's no alert
  end
end
