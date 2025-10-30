require "rails_helper"

RSpec.describe "Api::V1::Payments", type: :request do
  describe "GET /payments/new" do
    let(:patient) { create(:patient) }
    let(:doctor) { create(:doctor) }
    let(:appointment) { create(:appointment, doctor: doctor, patient: patient) }
    let(:bill) { create(:bill, appointment: appointment, tot_amount: 500, paid_amount: 0) }

    it "renders new" do
      get new_payment_path, params: { bill_id: bill.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /payments" do
    let(:patient) { create(:patient) }
    let(:doctor) { create(:doctor) }
    let(:appointment) { create(:appointment, doctor: doctor, patient: patient) }
    let(:bill) { create(:bill, appointment: appointment, tot_amount: 500, paid_amount: 0) }

    it "creates payment and redirects to patient path" do
      expect {
        post payments_path, params: { payment: { amount_to_be_paid: 100, payment_method: "card" }, bill_id: bill.id }
      }.to change(Payment, :count).by(1)

      expect(response).to redirect_to(patient_path(bill.appointment.patient.id))
    end

    it "renders new with unprocessable_entity when overpay" do
      bill.update(tot_amount: 100, paid_amount: 50)
      expect {
        post payments_path, params: { payment: { amount_to_be_paid: 100 }, bill_id: bill.id }
      }.not_to change(Payment, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
