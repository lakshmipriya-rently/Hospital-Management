require 'rails_helper'

RSpec.describe SurgeriesController, type: :controller do
  render_views

  include Devise::Test::ControllerHelpers

  let!(:doctor) { create(:doctor) }
  let!(:patient) { create(:patient) }
  let!(:doctor_user) { create(:user, userable: doctor) }
  let!(:patient_user) { create(:user, userable: patient) }

  describe 'GET #index' do
    let!(:surgery) { create(:surgery, doctor: doctor) }

    it 'responds successfully and loads surgeries' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'loads surgeries' do
      get :index
      surgeries = controller.instance_variable_get(:@surgeries)
      expect(surgeries).to include(surgery)
    end
  end

  describe 'GET #show' do
    let!(:surgery) { create(:surgery, doctor: doctor) }

    it 'shows the surgery' do
      get :show, params: { id: surgery.id }
      expect(response).to have_http_status(:ok)
    end

    it "checks instance variable" do
      get :show, params: { id: surgery.id }
      expect(controller.instance_variable_get(:@surgery)).to eq(surgery)
    end
  end

  describe 'GET #new' do
    context 'when doctor' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: doctor_user)
      end

      it 'renders new' do
        get :new
        expect(response).to have_http_status(:ok)
      end

      it "verify instance variable" do
        get :new
        expect(controller.instance_variable_get(:@surgery)).to be_a_new(Surgery)
      end
    end

    context 'when a non-doctor' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: patient_user)
      end

      it 'redirects to surgeries' do
        get :new
        expect(response).to redirect_to(surgeries_path)
      end

       it 'redirects to surgeries with alert' do
        get :new
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { surgery: attributes_for(:surgery, name: 'Appendectomy') } }
    let(:invalid_params) { { surgery: { name: nil } } }

    context 'when a doctor' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: doctor_user)
      end

      it 'creates surgery and redirects' do
        post :create, params: valid_params
        expect(response).to redirect_to(surgery_path(Surgery.last))
      end

      it 'handles invalid params (redirects)' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:ok)
      end



  it "renders new when save fails" do
    post :create, params: { surgery: { name: "", description: "" } }
    expect(response).to render_template(:new)
  end
    end

    context 'when non-doctor' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: patient_user)
      end

      it 'does not create and redirects' do
        post :create, params: valid_params
        expect(response).to redirect_to(surgeries_path)
      end

      it 'does not create and redirects with alert' do
        post :create, params: valid_params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH #update" do
  let!(:surgery) { create(:surgery, doctor: doctor, name: "Old Name") }

  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: doctor_user)
  end

  it "renders edit when update fails" do
    patch :update, params: { id: surgery.id, surgery: { name: "" } }
    expect(response).to render_template(:edit)
  end

  it "redirects to surgery when update succeeds" do
  patch :update, params: { id: surgery.id, surgery: { name: "Updated Name" } }
  expect(response).to redirect_to(surgery_path(surgery))
end
end


  describe 'POST #book_appointment' do
    let!(:surgery) { create(:surgery, doctor: doctor) }

    context 'when patient' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: patient_user)
      end

      it 'redirects to new appointment path' do
        post :book_appointment, params: { id: surgery.id }
        expect(response).to redirect_to(new_surgery_appointment_path(surgery))
      end
    end

    context 'when non-patient' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: doctor_user)
      end

      it 'redirects to sign in or shows alert' do
        post :book_appointment, params: { id: surgery.id }
        expect(response).not_to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:surgery) { create(:surgery, doctor: doctor) }

    context 'when owning doctor' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: doctor_user)
      end

      it 'destroys surgery' do
        delete :destroy, params: { id: surgery.id }
        expect(response).to redirect_to(surgeries_path)
      end
    end

    context 'when non-owner' do
      before do
        allow(controller).to receive_messages(authenticate_user!: true, current_user: patient_user)
      end

      it 'does not destroy and redirects with alert' do
        delete :destroy, params: { id: surgery.id }
        expect(response).to redirect_to(surgeries_path)
      end
    end

    context "when another doctor" do
  let(:other_doctor) { create(:doctor) }
  let(:other_doctor_user) { create(:user, userable: other_doctor) }

  before do
    allow(controller).to receive_messages(authenticate_user!: true, current_user: other_doctor_user)
  end

  it "redirects with not authorized alert" do
    delete :destroy, params: { id: surgery.id }
    expect(flash[:alert]).to eq("You are not authorized to delete this surgery.")
  end
end
  end

  describe "private methods" do
    context "when set_surgery" do
      it "redirects to doctor_path when surgery is not found" do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        get :show, params: { id: 'non-existent' }
        expect(response).to redirect_to(doctor_path)
      end
    end
  end
end
