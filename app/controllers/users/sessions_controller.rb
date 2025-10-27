class Users::SessionsController < Devise::SessionsController
  layout 'application'

  def create
    @login_attempted = true

    # Get sign in parameters
    params_hash = sign_in_params

    # Validate that email and password are present before attempting authentication
    user = resource_class.new(params_hash)
    user.validate(:login)

    if user.errors.any?
      self.resource = user
      render :new
    else
      # Let Devise handle the actual authentication
      super
    end
  end

  def after_sign_in_path_for(resource)
    root_path
  end

  protected

  def sign_in_params
    params.fetch(:user, {}).permit(:email, :password, :remember_me)
  end
end
