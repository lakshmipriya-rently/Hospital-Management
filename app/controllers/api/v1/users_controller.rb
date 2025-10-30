class Api::V1::UsersController < Api::V1::BaseController

  before_action :doorkeeper_authorize!
  before_action :authenticate_user!
  before_action :set_user,only: [:show]

  def index
    @users = User.all
  end

  def show
    if @user.id != current_user_api&.userable_id
      render json:{error:"You're not authorized to do that!"},status: :forbidden
    else
      render :show ,status: :ok
    end
  end
   
  private

  def set_user
    @user = User.find_by(id: params[:id])
    render json: { error: "User not found."}, status: :not_found unless @user
  end

end
