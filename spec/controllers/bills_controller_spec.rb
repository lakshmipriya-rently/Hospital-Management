require 'rails_helper'

RSpec.describe BillsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:doctor) { create(:doctor) }
  let(:doctor_user) { create(:user, userable: doctor) }
  let(:appointment_for_bill) { create(:appointment, doctor: doctor, patient: create(:patient)) }
  let(:bill) { create(:bill, appointment: appointment_for_bill) }

  before do
    allow(controller).to receive(:current_user).and_return(doctor_user)
  end

  describe 'PATCH #update' do
    context 'when bill is missing' do
      it 'redirects to doctor_path with alert' do
        aggregate_failures "response checks" do
          patch :update, params: { id: 0, bill: { tot_amount: 100 } }
          expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
          expect(flash[:alert]).to be_present
        end
      end
    end


    describe 'when bill exists' do
       before do
        allow_any_instance_of(Bill).to receive(:update).and_return(false)
      end


        it 'updates the bill and redirects with notice with valid params' do
             patch :update, params: { id: bill.id, bill: { tot_amount: 500 } }
            expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
        end

        it 'updates the bill' do
            patch :update, params: { id: bill.id, bill: { tot_amount: 500 } }
            expect(bill.reload.tot_amount).to eq(500)
        end


        it 'redirects to doctor_path does not change bill with invalid params' do
            patch :update, params: { id: bill.id, bill: { tot_amount: nil } }
            expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
        end

        it 'redirects to doctor_path with alert' do
            patch :update, params: { id: bill.id, bill: { tot_amount: nil } }
            expect(flash[:alert]).to be_present
        end
    end
  end
end
