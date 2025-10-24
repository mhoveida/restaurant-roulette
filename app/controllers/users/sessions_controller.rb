class Users::SessionsController < Devise::SessionsController
  layout 'application'

  def create
    # Mark that login was attempted so we show errors in the view
    @login_attempted = true

    # Validate that email and password are present before attempting authentication
    user = resource_class.new(sign_in_params)
    user.validate(:login)

    if user.errors.any?
      self.resource = user
      respond_with resource
    else
      super
    end
  end

  protected

  def sign_in_params
    params.fetch(:user, {}).permit(:email, :password, :remember_me)
  end
end
