class HomeController < ApplicationController
  def index
  end

  def redirect_by_role
     case current_user.userable_type
    when "Doctor"
      redirect_to doctor_path(current_user.userable)
    when "Patient"
      redirect_to patient_path(current_user.userable)
    when "Staff"
      redirect_to staffs_path(current_user.userable)
    else
      redirect_to unauthenticated_root_path
    end
  end
end
