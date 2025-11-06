class SurgeriesController < ApplicationController
  before_action :authenticate_user!, only: [ :book_appointment, :new, :create, :destroy ]
  before_action :set_surgery, only: [ :show, :book_appointment, :destroy, :edit, :update ]
  before_action :authorize_doctor!, only: [ :new, :create, :destroy ]

  def index
    @surgeries = Surgery.all
  end

  def show
  end

  def new
    @surgery = current_user.userable.surgeries.new
  end

  def create
    @surgery = current_user.userable.surgeries.new(surgery_params)
    if @surgery.save
      redirect_to @surgery, notice: "Surgery added successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @surgery.update(surgery_params)
      redirect_to @surgery, notice: "Surgery updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def book_appointment
    if current_user&.userable_type == "Patient"
      redirect_to new_surgery_appointment_path(@surgery)
    else
      redirect_to new_user_session_path, alert: "You must log in as a patient to book an appointment."
    end
  end

  def destroy
    if current_user&.userable_type == "Doctor" && @surgery.doctor == current_user.userable
      @surgery.destroy
      redirect_to surgeries_path, notice: "Surgery deleted successfully."
    else
      redirect_to surgeries_path, alert: "You are not authorized to delete this surgery."
    end
  end

  private

  def set_surgery
    @surgery = Surgery.find_by(id: params[:id])
    if @surgery.nil?
      redirect_to doctor_path, notice: "surgery not found"
    end
  end

  def surgery_params
    params.require(:surgery).permit(:name, :description, :doctor_id)
  end

  def authorize_doctor!
    unless current_user.userable_type == "Doctor"
      redirect_to surgeries_path, alert: "You are not authorized."
    end
  end
end
