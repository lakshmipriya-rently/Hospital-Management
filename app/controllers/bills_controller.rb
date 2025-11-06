class BillsController < ApplicationController
  before_action :set_bill, only: [ :update ]

  def update
    unless @bill
      redirect_to doctor_path(current_user.userable_id), alert: "Bill not found." and return
    end

    if @bill.update(bill_params)
      redirect_to doctor_path(current_user.userable_id), notice: "Fee updated successfully!"
    else
      redirect_to doctor_path(current_user.userable_id), alert: "Update Failed: #{@bill.errors.full_messages}"
    end
  end
private

  def set_bill
    @bill = Bill.find_by(id: params[:id])
  end

  def bill_params
    params.require(:bill).permit(:tot_amount)
  end
end
