class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json

  private

  def current_user_api
    @current_user ||= User.find_by(id: doorkeeper_token&.resource_owner_id)
  end

  def authenticate_user!
    render json: { error: "Unauthorized User" }, status: :unauthorized unless current_user_api
  end
end
