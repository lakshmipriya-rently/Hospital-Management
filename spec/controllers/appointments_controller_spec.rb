require 'rails_helper'

RSpec.describe AppointmentsController, type: :controller do
  render_views

  include Devise::Test::ControllerHelpers

  let(:doctor) { create(:doctor) }
  let(:patient) { create(:patient) }
  let(:doctor_user) { create(:user, userable: doctor) }
  let(:patient_user) { create(:user, userable: patient) }

  describe 'GET #new' do
    before do
      allow(controller).to receive(:set_appointment_context) do
        controller.instance_variable_set(:@doctor, doctor)
        controller.instance_variable_set(:@surgery, nil)
      end
      allow(controller).to receive(:authenticate_patient!).and_return(true)
      allow(controller).to receive(:current_user).and_return(patient_user)
      get :new
    end

    it 'returns http success' do
      expect(response).to have_http_status(:ok)
    end

    it 'builds a new appointment' do
      appt = controller.instance_variable_get(:@appointment)
      expect(appt).to be_a_new(Appointment)
    end
  end

  describe 'POST #create' do
    before do
      allow(controller).to receive(:set_appointment_context) do
        controller.instance_variable_set(:@doctor, doctor)
        controller.instance_variable_set(:@surgery, nil)
      end
      allow(controller).to receive(:authenticate_patient!).and_return(true)
      allow(controller).to receive(:current_user).and_return(patient_user)
    end

    context 'with valid params' do
      let(:valid_params) { { appointment: attributes_for(:appointment, scheduled_at: 1.day.from_now, disease: 'Cough') } }

      it 'creates an appointment and redirects to patient' do
        expect {
          post :create, params: valid_params
        }.to change(Appointment, :count).by(1)

        expect(response).to redirect_to(patient_path(assigns_patient = Appointment.last.patient))
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { appointment: { scheduled_at: nil, disease: nil } } }

      it 'renders new with unprocessable_entity' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Appointment') # view rendered
      end
    end
  end

  describe 'GET #show' do
    let!(:patient_user) { create(:user, userable: patient) }
    let!(:doctor_user) { create(:user, userable: doctor) }
    let!(:appointment) { create(:appointment, doctor: doctor, patient: patient) }

    it 'shows the appointment' do
      get :show, params: { id: appointment.id }
      expect(response).to have_http_status(:ok)
      assigned = controller.instance_variable_get(:@appointment)
      expect(assigned).to eq(appointment)
    end
  end

  describe 'PATCH #update' do
    let!(:appointment) { create(:appointment, doctor: doctor, patient: patient, disease: 'Old') }

    context 'when doctor is authorized' do
      before do
        allow(controller).to receive(:authenticate_doctor!).and_return(true)
        allow(controller).to receive(:current_user).and_return(doctor_user)
      end

      it 'updates appointment with valid params and redirects' do
        patch :update, params: { id: appointment.id, appointment: { disease: 'New' } }
        expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
        expect(appointment.reload.disease).to eq('New')
      end
    end

    context 'when doctor provides invalid params' do
      before do
        allow(controller).to receive(:authenticate_doctor!).and_return(true)
        allow(controller).to receive(:current_user).and_return(doctor_user)
      end

      it 'redirects back with alert' do
        patch :update, params: { id: appointment.id, appointment: { scheduled_at: nil } }
        expect(response).to redirect_to(doctor_path(doctor_user.userable_id))
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "private methods" do
    context "when unauthenticated" do
      before { get :show , params:{ id: 9999 } }
       it "redirects to the unauthenticated root path" do
          expect(response).to redirect_to(unauthenticated_root_path)
       end
    end

    context "when unauthenticated patient" do
      before { get :new , params:{ id: 9999 } }
       it "redirects to the unauthenticated root path" do
          expect(response).to redirect_to(new_user_session_path)
       end
    end

    context "when unauthenticated doctor" do
      before { post :update , params:{ id: 9999 } }
       it "redirects to the unauthenticated root path" do
          expect(response).to redirect_to(new_user_session_path)
       end
    end
  end
end
