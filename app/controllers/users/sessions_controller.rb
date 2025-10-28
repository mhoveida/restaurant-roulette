class Users::SessionsController < Devise::SessionsController
  layout "application"

  def create
    @login_attempted = true
    # Let Devise handle the authentication completely
    super
  end

  def after_sign_in_path_for(resource)
    root_path
  end
end