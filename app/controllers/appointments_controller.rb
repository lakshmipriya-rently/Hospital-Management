class AppointmentsController < ApplicationController
  def new
      @patient_id = params[:patient_id]
      @doctor_id = params[:doctor_id]
      @appointment = Appointment.new
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.status = :pending
    if @appointment.save
      puts "in appointment patient id :#{@appointment.patient.id}"
      redirect_to patient_path(@appointment.patient.id), notice: "Appointment booked successfully."
    else
      puts @appointment.errors.full_messages

      render :new, status: :unprocessable_entity
    end
  end
  


  def update
  @appointment = Appointment.find(params[:id])
  if @appointment.update(appointment_params)
    redirect_to appointments_path, notice: "Appointment updated successfully."
  else
    render :edit, status: :unprocessable_entity
  end
end

  private

  def appointment_params
    params.require(:appointment).permit(
      :appointment_date, 
      :appointment_time, 
      :patient_id, 
      :doctor_id,
      :status
    )
  end
end
