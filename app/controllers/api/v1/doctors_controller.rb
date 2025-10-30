class Api::V1::DoctorsController < Api::V1::BaseController
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  before_action :doorkeeper_authorize!
  before_action :set_doctor, only: [:show, :update]
  before_action :authenticate_user!
  # before_action :check_if_appointment_expired, only: [:show]

  def index
    @doctors = Doctor.all
    render json: @doctors, status: :ok
  end

  def show
    if @doctor.id != current_user_api&.userable_id
      render json: { error: "You're not authorized to do that!" }, status: :forbidden
    else
      render json: @doctor.as_json(only: [:id, :name, :email]), status: :ok
    end
  end

  def update
    if @doctor.id != current_user_api&.userable_id
      render json: { error: "You're not authorized to do that!" }, status: :forbidden
    elsif @doctor.update(doctor_params)
      render json: @doctor.available.as_json(only: [:start_time, :end_time, :available_days]), status: :ok
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def doctor_params
    params.require(:doctor).permit(
      available_attributes: [:start_time, :end_time, { available_days: [] }],
    )
  end

  def set_doctor
    @doctor = Doctor.find_by(id: params[:id])
    render json: { error: "Doctor not found." }, status: :not_found unless @doctor
  end

  # def check_if_appointment_expired
  #   @appointments = @doctor.appointments.order(scheduled_at: :asc)
  #   @appointments.each do |appointment|
  #     if appointment.scheduled_at.to_date < Date.today
  #       appointment.update(status: :cancelled)
  #     end
  #   end
  # end

  def handle_parameter_missing(exception)
    render json: { errors: [exception.message] }, status: :bad_request
  end
end
