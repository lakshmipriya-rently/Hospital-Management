class PatientsController < ApplicationController
    def new
        @user = User.find(params[:user_id])
        puts "user id--------------> #{params[:user_id]}"
        @patient = Patient.new
    end

    def index
        @doctors = Doctor.includes(:users).all
        @patients = Patient.all
        @patient_id = params[:patient_id]
    end

    def create
      @user = User.find(params[:user_id])
      @patient = Patient.new(patient_params)
      @user.update(userable: @patient)

      if @patient.save
        redirect_to patients_path(patient_id: @patient.id), notice: "Patient profile created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

     def show
       @patient= Patient.find(params[:id])
       @appointments = @patient.appointments.order(appointment_date: :desc)
       @bills = @appointments.map(&:bill).compact
     end

    private

    def patient_params
      params.require(:patient).permit(:blood_group, :disease, :organ_donor, :address)
    end
end
