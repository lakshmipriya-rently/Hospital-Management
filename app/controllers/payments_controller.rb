class PaymentsController < ApplicationController
  before_action :set_bill, only: [:new, :create]
  before_action :set_payments, only: [:show]

  def new
    @patient_id = params[:patient_id]
    @payment = Payment.new(bill: @bill)
  end

  def show
  end

  def create
    @payment = Payment.new(payment_params)
    @payment.bill = @bill

    if @payment.save
      redirect_to patient_path(@bill.appointment.patient.id), notice: "Payment processed successfully."
    else
      flash.now[:alert] = "Payment could not be processed."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_bill
    @bill = Bill.find_by(id: params[:bill_id])
    unless @bill
      redirect_to patients_path, alert: "Bill not found"
    end
  end

  def set_payments
    @payments = Payment.where(bill_id: params[:bill_id]).order(:created_at)
  end

  def payment_params
    params.require(:payment).permit(:amount_to_be_paid, :payment_method, :status, :bill_id)
  end
end
