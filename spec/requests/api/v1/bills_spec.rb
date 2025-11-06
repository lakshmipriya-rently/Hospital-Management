require "rails_helper"

RSpec.describe "Api::V1::Bills", type: :request do
  describe "PATCH /bills/:id" do
    let(:doctor_user) { create(:user, :doctor) }
    let(:patient) { create(:patient) }
    let(:appointment) { create(:appointment, doctor: doctor_user.userable, patient: patient) }
    let(:bill) { create(:bill, appointment: appointment, tot_amount: 500, paid_amount: 0) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(doctor_user)
    end

    it "updates bill and redirects with notice" do
      patch "/bills/#{bill.id}", params: { bill: { tot_amount: 1000 } }
      expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
    end

    it "updates bill and reload tot_amount" do
      patch "/bills/#{bill.id}", params: { bill: { tot_amount: 1000 } }
      expect(bill.reload.tot_amount.to_i).to eq(1000)
    end

    it "redirects with alert when bill not found" do
      patch "/bills/99999", params: { bill: { tot_amount: 1000 } }
      expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
    end
  end
end
