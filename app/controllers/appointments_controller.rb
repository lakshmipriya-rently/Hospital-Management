class AppointmentsController < ApplicationController
  before_action :authenticate_patient!, only: [:new, :create]
  before_action :authenticate_doctor!, only: [:update]
  before_action :set_appointment_context, only: [:new, :create]
  before_action :set_appointment, only: [:show, :update]

  def new
    @appointment = Appointment.new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.doctor = @doctor
    @appointment.patient = current_user.userable
    @appointment.surgery = @surgery
    @appointment.status = :pending

    if @appointment.save
      redirect_to patient_path(@appointment.patient), notice: "Appointment booked successfully."
    else
      render :new,status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    if @appointment.update(appointment_params)
      flash[:notice] = "Appointment updated successfully."
      redirect_to doctor_path(current_user.userable_id)
    else
      redirect_to doctor_path(current_user.userable_id), alert: "Update failed: #{@appointment.errors.full_messages.to_sentence}"
    end
  end

  private

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
    else
      redirect_back(fallback_location: surgeries_path, alert: "Cannot determine doctor or surgery") and return
    end
  end

  def set_appointment
    @appointment = Appointment.find_by(id: params[:id])
    if @appointment.nil?
      redirect_to unauthenticated_root_path, alert: "You're not authorized to view appointment"
    end
  end

  def authenticate_patient!
    unless current_user&.userable_type == "Patient"
      redirect_to new_user_session_path, alert: "You must log in as a patient to book an appointment."
    end
  end

  def authenticate_doctor!
    unless current_user.userable_type == "Doctor"
      redirect_to new_user_session_path, alert: "You must log in as a doctor to update an appointment."
    end
  end
end
