class DoctorsController < ApplicationController
  before_action :set_doctor
  before_action :check_if_appointment_expired, only: [ :show ]

  def index
    @doctors = Doctor.all
  end

  def show
  end

  def edit
    @doctor.build_available if @doctor.available.nil?
  end

  def update
    if @doctor.update(doctor_params)
      redirect_to doctor_path(@doctor), notice: "Doctor Available Updated Successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_doctor
    @doctor = Doctor.find_by(id: params[:id])
  end

  def doctor_params
    params.require(:doctor).permit(
      available_attributes: [ :start_time, :end_time, :is_active, { available_days: [] } ],
    )
  end

  def check_if_appointment_expired
    @appointments = @doctor.appointments.order(scheduled_at: :asc)
    @appointments = @doctor.appointments.includes(:bill)
    if @appointments.any?
      @appointments.each do |appointment|
        if appointment.scheduled_at.to_date < Date.today
          appointment.update(status: :cancelled)
        end
      end
    end
  end
end
