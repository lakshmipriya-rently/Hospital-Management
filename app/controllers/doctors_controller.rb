class DoctorsController < ApplicationController
    def index
      @doctors = Doctor.all 
      @doctor_id = params[:doctor_id]
      @appointments = Appointment.where(doctor_id: @doctor_id)
    end

    def new
      @user = User.find(params[:user_id])
      @doctor = Doctor.new
      @doctor.specializations.build
      @doctor.build_available
    end

    def create
      @user = User.find(params[:user_id])
      @doctor = Doctor.new(doctor_params)

      if @doctor.save
        @user.update(userable: @doctor)
        redirect_to doctors_path(doctor_id: @doctor.id), notice: "Doctor profile created successfully."
      else
        @doctor.build_available if @doctor.available.nil? 
        render :new, status: :unprocessable_entity
      end
    end


   
    def doctor_params
      params.require(:doctor).permit(
            :license_id,
            :experience,
            :type_of_degree,
            :salary,
            specialization_ids: [],
            available_attributes: [
            :start_time,
            :end_time,
            :is_active,
            { available_days: [] }
        ]
      )
    end




end
