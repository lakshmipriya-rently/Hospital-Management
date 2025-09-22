class PaymentsController < ApplicationController
    def new
        @bill_id = params[:bill_id]
        @patient_id = params[:patient_id]
        @payment = Payment.new
    end
    def create
        @payment = Payment.new(payment_params)
        @bill = Bill.find(payment_params[:bill_id])

        if @payment.save
            redirect_to patient_path(@bill.appointment.patient.id)
            puts "successfully saved"
        else
            puts @payment.errors.full_messages
            puts "payment data not saved"
            render :new
        end
    end

    private

    def payment_params
        params.require(:payment).permit(:amount_to_be_paid, :payment_method, :status, :bill_id)
    end
end
