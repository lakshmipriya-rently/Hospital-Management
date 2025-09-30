class PatientsController < ApplicationController
    def index
        @doctors = Doctor.includes(:user).all
        @patients = Patient.all
        @patient_id = params[:patient_id]
    end

    def show
       @patient= Patient.find(params[:id])
       @appointments = @patient.appointments.order(scheduled_at: :desc)
       @bills = @appointments.map(&:bill).compact
    end
end
