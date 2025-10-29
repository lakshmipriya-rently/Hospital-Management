class Api::V1::PatientsController < Api::V1::BaseController
  before_action :doorkeeper_authorize!
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  before_action :set_patient, only: [:show, :update, :confirmed]
  before_action :authenticate_user!

  def index
    @patients = Patient.all
    render :index, status: :ok
  end

  def show
    if @patient.id != current_user_api&.userable_id
      render json: { error: "You're not authorized to do that!" }, status: :forbidden
    else
      render :show, status: :ok
    end
  end

  def update
    if @patient.id != current_user_api&.userable_id
      render json: { error: "You're not authorized to do that!" }, status: :forbidden
    elsif @patient.update(patient_params)
      render :show, status: :ok
    else
      render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def confirmed
    if current_user_api&.userable_type == "Patient"
      if @patient.id != current_user_api&.userable_id
        render json: { error: "You can't access other records" }, status: :forbidden
      else
        @confirmed_appointments = @patient.appointments.where(status: "confirmed").order(scheduled_at: :desc)
        if @confirmed_appointments.nil?
          @confirmed_appointments = []
        end
        render json: { patient: @patient.id, appointments: @confirmed_appointments.map do |appointment| {
                 id: appointment.id,
                 scheduled_at: appointment.scheduled_at,
                 disease: appointment.disease,
                 status: appointment.status,
               }                end }, status: :ok
      end
    else
      render json: { error: "You're not authorized to view appointments" }, status: :unauthorized
    end
  end

  private

  def set_patient
    @patient = Patient.find_by(id: params[:id])
    render json: { error: "Patient not found." }, status: :not_found unless @patient
  end

  def patient_params
    params.require(:patient).permit(:blood_group, :address)
  end

  def handle_parameter_missing(exception)
    render json: { errors: [exception.message] }, status: :bad_request
  end
end
