RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :feature

  config.before(:each, type: :controller) do
    # Ensure Devise mapping is configured for controller tests
    @request.env["devise.mapping"] = Devise.mappings[:user] if @request
  end
end
