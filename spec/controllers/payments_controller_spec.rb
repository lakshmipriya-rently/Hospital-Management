require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:patient) { create(:patient) }
  let(:user) { create(:user, userable: patient) }
  let(:appointment) { create(:appointment, patient: patient) }
  let(:bill) { create(:bill, appointment: appointment) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #new' do
    context 'when bill exists' do
      before { get :new, params: { bill_id: bill.id, patient_id: patient.id } }

      it 'assigns a new payment with bill set' do
        aggregate_failures "response checks" do
          expect(assigns(:payment)).to be_a_new(Payment)
          expect(assigns(:payment).bill).to eq(bill)
        end
      end

      it 'sets patient_id variable' do
        expect(assigns(:patient_id)).to eq(patient.id.to_s).or eq(patient.id)
      end
    end

    context 'when bill not found' do
      it 'redirects to patients_path with alert' do
        get :new, params: { bill_id: 0 }
         aggregate_failures "response checks" do
            expect(response).to redirect_to(patients_path)
            expect(flash[:alert]).to be_present
         end
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { { payment: attributes_for(:payment, amount_to_be_paid: bill.tot_amount), bill_id: bill.id } }

      it 'creates a payment and redirects to patient' do
         aggregate_failures "response checks" do
            expect {
              post :create, params: valid_params
            }.to change(Payment, :count).by(1)

            expect(response).to redirect_to(patient_path(bill.appointment.patient.id))
            expect(flash[:notice]).to be_present
          end
        end
    end

    context 'with invalid params' do
      let(:invalid_params) { { payment: { amount_to_be_paid: nil }, bill_id: bill.id } }

      it 'does not create payment and renders new with 422' do
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
         aggregate_failures "response checks" do
            expect {
              post :create, params: invalid_params
            }.not_to change(Payment, :count)

            expect(response).to have_http_status(:unprocessable_entity)
            expect(flash[:alert]).to eq('Payment could not be processed.').or be_present
            expect(response).to render_template(:new)
         end
      end
    end
  end

  describe 'GET #show' do
    it 'assigns payments for the bill' do
      p1 = create(:payment, bill: bill)
      p2 = create(:payment, bill: bill)
      get :show, params: { id: 1, bill_id: bill.id }
      aggregate_failures "response checks" do
        expect(assigns(:payments)).to include(p1, p2)
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
