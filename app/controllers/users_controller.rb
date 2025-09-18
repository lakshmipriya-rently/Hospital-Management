class UsersController < ApplicationController
   
    def new 
        @user = User.new 
    end

    def create
        @user = User.new(user_params.except(:userable_type))
        userable_type = params[:user][:userable_type].downcase
        if @user.save
            case userable_type
            when "doctor"
             redirect_to new_doctor_path(user_id: @user.id),notice:'User was successfully created'
            when "patient"
             redirect_to new_patient_path(user_id: @user.id),notice:'User was successfully created'
            when "staff"
             redirect_to new_staff_path(user_id: @user.id),notice:'User was successfully created'
            end
        else
          render :new,status: :unprocessable_entity
        end
    end

    def user_params
        params.require(:user).permit(:name,:email,:phone_no,:dob,:age,:gender,:userable_type)
    end
end
