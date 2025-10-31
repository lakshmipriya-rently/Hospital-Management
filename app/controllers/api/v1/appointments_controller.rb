class Api::V1::AppointmentsController < Api::V1::BaseController
  before_action :authenticate_patient_api!, only: [:create]
  before_action :set_appointment_context, only: [:create]
  before_action :authenticate_doctor_api!, only: [:update]
  before_action :set_appointment, only: [:update]
  before_action :doorkeeper_authorize!, unless: -> { Rails.env.test? }
  before_action :authenticate_user!, unless: -> { Rails.env.test? }

  def index
    @appointments = Appointment.all
    render :index, status: :ok
  end

  def show
     @appointment = Appointment.find_by(id: params[:id])
     render json:@appointment,status: :ok
  end


  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.doctor = @doctor
    @appointment.patient = current_user.userable
    @appointment.surgery = @surgery
    @appointment.status = :pending

    if @appointment.save
      render json: @appointment, status: :created, location: api_v1_appointment_url(@appointment)
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @appointment.update(appointment_params)
      render json: @appointment, status: :ok
    else
      render json: { errors: @appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find_by(id: params[:id])
    unless @appointment
      render json: { error: "Appointment not found" }, status: :not_found
    end
  end

  def appointment_params
    params.require(:appointment).permit(:scheduled_at, :disease, :surgery_id, :doctor_id, :patient_id, :status)
  end

  def set_appointment_context
    surgery_id = params[:surgery_id] || params.dig(:appointment, :surgery_id)
    doctor_id = params[:doctor_id] || params.dig(:appointment, :doctor_id)

    if surgery_id.present?
      @surgery = Surgery.find_by(id: surgery_id)
      @doctor = @surgery&.doctor
    elsif doctor_id.present?
      @doctor = Doctor.find_by(id: doctor_id)
      @surgery = nil
    end

    unless @doctor.present?
      render json: { error: "Cannot determine doctor from provided context (surgery_id or doctor_id)." }, status: :bad_request and return
    end
  end

  def authenticate_patient_api!
    unless current_user&.userable_type == "Patient"
      render json: { error: "Unauthorized. Must be logged in as a patient." }, status: :unauthorized and return
    end
  end

  def authenticate_doctor_api!
    unless current_user&.userable_type == "Doctor"
      render json: { error: "Unauthorized. Must be logged in as a doctor." }, status: :unauthorized and return
    end
  end

end