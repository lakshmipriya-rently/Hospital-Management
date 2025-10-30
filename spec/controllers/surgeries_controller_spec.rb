require 'rails_helper'

RSpec.describe SurgeriesController, type: :controller do
  render_views

  include Devise::Test::ControllerHelpers

  let(:doctor) { create(:doctor) }
  let(:patient) { create(:patient) }
  let(:doctor_user) { create(:user, userable: doctor) }
  let(:patient_user) { create(:user, userable: patient) }

  describe 'GET #index' do
    let!(:doctor_user) { create(:user, userable: doctor) }
    let!(:surgery) { create(:surgery, doctor: doctor) }

    it 'responds successfully and loads surgeries' do
      get :index
      expect(response).to have_http_status(:ok)
      surgeries = controller.instance_variable_get(:@surgeries)
      expect(surgeries).to include(surgery)
    end
  end

  describe 'GET #show' do
    let!(:doctor_user) { create(:user, userable: doctor) }
    let!(:surgery) { create(:surgery, doctor: doctor) }

    it 'shows the surgery' do
      get :show, params: { id: surgery.id }
      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@surgery)).to eq(surgery)
    end
  end

  describe 'GET #new' do
    context 'as a doctor' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(doctor_user)
      end

      it 'renders new' do
        get :new
        expect(response).to have_http_status(:ok)
        expect(controller.instance_variable_get(:@surgery)).to be_a_new(Surgery)
      end
    end

    context 'as a non-doctor' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(patient_user)
      end

      it 'redirects to surgeries with alert' do
        get :new
        expect(response).to redirect_to(surgeries_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { surgery: attributes_for(:surgery, name: 'Appendectomy') } }
    let(:invalid_params) { { surgery: { name: nil } } }

    context 'as a doctor' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(doctor_user)
      end

      it 'creates surgery and redirects' do
        expect { post :create, params: valid_params }.to change(Surgery, :count).by(1)
        expect(response).to redirect_to(surgery_path(Surgery.last))
      end

      it 'handles invalid params (redirects)' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:found)
      end
    end

    context 'as non-doctor' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(patient_user)
      end

      it 'does not create and redirects with alert' do
        expect { post :create, params: valid_params }.not_to change(Surgery, :count)
        expect(response).to redirect_to(surgeries_path)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST #book_appointment' do
    let!(:surgery) { create(:surgery, doctor: doctor) }

    context 'as patient' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(patient_user)
      end

      it 'redirects to new appointment path' do
        post :book_appointment, params: { id: surgery.id }
        expect(response).to redirect_to(new_surgery_appointment_path(surgery))
      end
    end

    context 'as non-patient' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(doctor_user)
      end

      it 'redirects to sign in or shows alert' do
        post :book_appointment, params: { id: surgery.id }
        expect(response).to_not have_http_status(:ok)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:surgery) { create(:surgery, doctor: doctor) }

    context 'as owning doctor' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(doctor_user)
      end

      it 'destroys surgery' do
        expect { delete :destroy, params: { id: surgery.id } }.to change(Surgery, :count).by(-1)
        expect(response).to redirect_to(surgeries_path)
      end
      
    end

    context 'as non-owner' do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(patient_user)
      end

      it 'does not destroy and redirects with alert' do
        expect { delete :destroy, params: { id: surgery.id } }.not_to change(Surgery, :count)
        expect(response).to redirect_to(surgeries_path) 
      end
    end
  end

  describe "private methods" do
    context "set_surgery" do
      it "redirects to doctor_path when surgery is not found" do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        get :show, params: { id: 'non-existent' }
        expect(response).to redirect_to(doctor_path)
      end
    end
  end
end
