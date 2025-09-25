class DoctorsController < ApplicationController
  def show
    @doctor = Doctor.find_by(id: params[:id])
    if @doctor.nil?
       redirect_to home_index_path, alert: "You are not authorized to access this page"
    else
      @appointments = @doctor.appointments
    end
  end
end
