class Api::V1::SurgeriesController < ApplicationController
  before_action :doorkeeper_authorize!
  before_action :authenticate_user!
  before_action :set_surgery, only: [:show, :destroy]

  def index
    @surgeries = Surgery.all
    render json: @surgeries, status: :ok
  end

  def show
    if @surgery.nil?
      render json: { error: "Surgery not found" }, status: :not_found
    else
      render json: @surgery, status: :ok
    end
  end
  
  def create
    unless current_user&.userable_type == "Doctor"
      return render json: { error: "You are not authorized to create a surgery" }, status: :forbidden
    end

    @surgery = current_user.userable.surgeries.new(surgery_params)

    if @surgery.save
      render json: @surgery, status: :created
    else
      render json: { errors: @surgery.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user&.userable_type == "Doctor" && @surgery.doctor == current_user.userable
      @surgery.destroy
      head :no_content
    else
      render json: { error: "You are not authorized to delete this surgery" }, status: :forbidden
    end
  end

  def book_appointment
    unless current_user&.userable_type == "Patient"
      return render json: { error: "You must be logged in as a patient to book an appointment." }, status: :forbidden
    end
  end

  private

  def set_surgery
    @surgery = Surgery.find(params[:id])
  end

  def surgery_params
    params.require(:surgery).permit(:name, :description, :doctor_id)
  end
 
end
