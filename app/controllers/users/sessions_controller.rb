class Users::SessionsController < Devise::SessionsController
  layout 'application'

  def create
    # Mark that login was attempted so we show errors in the view
    @login_attempted = true

    # Get sign in parameters
    params_hash = sign_in_params

    # Validate that email and password are present before attempting authentication
    user = resource_class.new(params_hash)
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
