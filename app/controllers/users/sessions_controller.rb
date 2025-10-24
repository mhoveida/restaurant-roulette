class Users::SessionsController < Devise::SessionsController
  layout 'application'

  def create
    super do |resource|
      if !resource.persisted?
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
        return
      end
    end
  end
end
