class DoctorsController < ApplicationController

  def show
    @doctor = Doctor.find(params[:id])
    @appointments = @doctor.appointments
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
    @user.update(userable: @doctor)

    if @doctor.save
      redirect_to doctor_path(@doctor), notice: "Doctor profile created successfully."
    else
      @doctor.build_available if @doctor.available.nil?
      render :new, status: :unprocessable_entity
    end
  end

  private

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
