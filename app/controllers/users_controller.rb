class UsersController < ApplicationController

    def new 
        puts "inside the user page"
        @user = User.new
        p @user.errors.full_messages
        p "#{params.inspect}"
    end
    
    def create
        puts "inside the create"
        @user = User.new(user_params)
        userable_type = params[:user][:userable_type]
        p "#{user_params}"
        if @user.save
            case userable_type
            when "Doctor"
             redirect_to new_doctor_path(user_id: @user.id),notice:'User was successfully created'
            when "Patient"
             redirect_to new_patient_path(user_id: @user.id),notice:'User was successfully created'
            when "Staff"
             redirect_to new_staff_path(user_id: @user.id),notice:'User was successfully created'
            end
        else
          puts @user.errors.full_messages
          render :new,status: :unprocessable_entity
        end
    end

    private

    def user_params
        params.require(:user).permit(:name,:phone_no,:dob,:age,:gender)
    end
end
