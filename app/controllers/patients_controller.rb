class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :edit, :update, :destroy, :confirmed]
  before_action :check_and_update_status, only: [:show]

  def index
    @doctors = Doctor.includes(:user).all
    @patients = Patient.all
  end

  def show
   if @patient
     @appointments = @patient.appointments.order(scheduled_at: :desc)
     @bills = @appointments.map(&:bill).compact
   else
     redirect_to unauthenticated_root_path, alert: "Patient not found."
   end
  end

  def edit
    @patient.build_user if @patient.user.nil?
  end

  def update
    if @patient.update(patient_params)
      redirect_to patient_path, notice: "Profile Updated"
    else
      render :edit, status: :unprocessable_entity 
    end
  end

  def confirmed
    @appointments = @patient.appointments.where(status: "confirmed").order(scheduled_at: :desc)
  end

  def destroy
    @patient.destroy
    redirect_to unauthenticated_root_path, notice: "Patient and their appointments deleted successfully."
  end

  private

  def patient_params
    params.require(:patient).permit(:blood_group, :address, :organ_donor)
  end

  def set_patient
    @patient = Patient.find_by(id: params[:id])
  end

  def check_and_update_status
    if @patient
    bills = @patient.appointments.includes(:bill).map(&:bill).compact
    bills.each do |bill|
      next unless bill.payment.present?
      if bill.paid_amount == bill.tot_amount
        bill.payment.update_columns(status: :paid)
      elsif bill.paid_amount == 1
        bill.payment.update_columns(status: :un_paid)
      else
        bill.payment.update_columns(status: :pending)
      end
    end
  end
  end
end
