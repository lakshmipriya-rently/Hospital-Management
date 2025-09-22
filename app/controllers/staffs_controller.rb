class StaffsController < ApplicationController
     def index 
        @appointments = Appointment.confirmed
     end
     def new
        @user = User.find(params[:user_id])
        @staff = Staff.new
     end
     def create
      @user = User.find(params[:user_id])
      @staff = Staff.new(staff_params)

      if @staff.save
        @user.update(userable: @staff)
        redirect_to staffs_path, notice: "Staff profile created successfully."
      else
        render :new,status: :unprocessable_entity
      end
    end
   
    private
    
    def staff_params
      params.require(:staff).permit(:is_permanant,:salary,:qualification,:shift)
    end

end
