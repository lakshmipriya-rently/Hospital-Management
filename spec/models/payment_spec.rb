require "rails_helper"

RSpec.describe Payment, type: :model do
  context "validations" do
    it "validates the payment is not greater than remaining" do
      bill = Bill.create(tot_amount: 500, paid_amount: 0.0)
      payment = Payment.new(amount_to_be_paid: 600, bill: bill)
      payment.validate
      expect(payment.errors[:amount_to_be_paid]).to include("cannot be greater than the remaining bill amount")
    end
  end

  describe "scopes" do
    describe "un_paid" do
      it "returns the payment where the status is un paid" do
        appointment = FactoryBot.create(:appointment)
        bill = FactoryBot.create(:bill, tot_amount: 500, paid_amount: 0.0, appointment: appointment)
        un_paid_payment = create(:payment, status: :un_paid, bill: bill)
        expect(Payment.un_paid).to include(un_paid_payment)
      end
    end

    describe "paid" do
      it "returns the payment where the status is paid" do
        appointment = FactoryBot.create(:appointment)
        bill = FactoryBot.create(:bill, tot_amount: 500, paid_amount: 0.0, appointment: appointment)
        paid_payment = create(:payment, status: :paid, bill: bill, amount_to_be_paid: 500)
        expect(Payment.paid).to include(paid_payment)
      end
    end
  end

  describe "after_create :update_payment_status" do
    let(:appointment) { create(:appointment) }
    let(:bill) { create(:bill, tot_amount: 500, paid_amount: 0.0, appointment: appointment) }

    it "increments the bill's paid_amount by the payment amount" do
      payment = create(:payment, amount_to_be_paid: 200, status: :paid, bill: bill)
      bill.reload
      expect(bill.paid_amount).to eq(200)
    end
  end
end
