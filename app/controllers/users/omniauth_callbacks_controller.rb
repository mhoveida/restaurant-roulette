class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2

    Rails.logger.debug ">>> CALLBACK URL: #{request.original_url}"

    # Add detailed logging
    Rails.logger.debug "=" * 80
    Rails.logger.debug "OmniAuth Auth Hash:"
    Rails.logger.debug request.env['omniauth.auth'].inspect
    Rails.logger.debug "=" * 80
    Rails.logger.debug "OmniAuth Params:"
    Rails.logger.debug request.env['omniauth.params'].inspect
    Rails.logger.debug "=" * 80

    Rails.logger.info("[DEBUG] OmniAuth raw info: #{request.env['omniauth.auth'].inspect}")
    Rails.logger.info("[DEBUG] OmniAuth credentials: #{request.env['omniauth.auth']&.dig('credentials').inspect}")
    
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      Rails.logger.error "User persistence failed: #{@user.errors.full_messages}"
      session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    Rails.logger.error "=" * 80
    Rails.logger.error "OmniAuth Failure:"
    Rails.logger.error "Message: #{params[:message]}"
    Rails.logger.error "Strategy: #{params[:strategy]}"
    Rails.logger.error "Error: #{request.env['omniauth.error']}"
    Rails.logger.error "Error Type: #{request.env['omniauth.error.type']}"
    Rails.logger.error "Error Strategy: #{request.env['omniauth.error.strategy']}"
    Rails.logger.error "=" * 80
    
    redirect_to root_path, alert: "Authentication failed: #{params[:message] || 'Unknown error'}"
  end
end