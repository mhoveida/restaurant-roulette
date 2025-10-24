class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authentication guards - add these before_action filters to protect routes
  # before_action :authenticate_user! # Require authentication on all routes
  # For specific controllers:
  # class SomeController < ApplicationController
  #   before_action :authenticate_user!, only: [:edit, :update, :destroy]
  # end
end
