class BillsController < ApplicationController
    def new
        @bill = Bill.new
        @appointment_id = params[:appointment_id]
        puts  "appointment id #{@appointment_id}"
    end
    def create
        @bill = Bill.new(bill_params)
        puts "bill params #{params.inspect}"
       
        
         if @bill.save
            redirect_to staffs_path,notice: 'Bill has successfully assigned'
        else
            puts " bill errors ------------->"
            puts @bill.errors.full_messages
            render :new,status: :unprocessable_entity
        end
    end
    def bill_params
        params.require(:bill).permit(:bill_date,:tot_amount,:paid_amount,:appointment_id,:is_assigned)
    end
end
