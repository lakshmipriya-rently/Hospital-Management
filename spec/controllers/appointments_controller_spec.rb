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

     describe "private method #set_appointment_context" do
    controller(AppointmentsController) do
      def index
        set_appointment_context
        head :ok unless performed?
      end
    end

    let!(:doctor) { create(:doctor) }
    let!(:surgery) { create(:surgery, doctor: doctor) }

    context "when surgery_id is present" do
      it "assigns surgery correctly" do
        get :index, params: { surgery_id: surgery.id }
        expect(assigns(:surgery)).to eq(surgery)
      end

      it "assigns doctor correctly" do
        get :index, params: { surgery_id: surgery.id }
        expect(assigns(:doctor)).to eq(doctor)
      end

      it "responds with ok status" do
        get :index, params: { surgery_id: surgery.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when doctor_id is present" do
      it "assigns doctor correctly" do
        get :index, params: { doctor_id: doctor.id }
        expect(assigns(:doctor)).to eq(doctor)
      end

      it "assigns surgery as nil" do
        get :index, params: { doctor_id: doctor.id }
        expect(assigns(:surgery)).to be_nil
      end

      it "responds with ok status" do
        get :index, params: { doctor_id: doctor.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when neither surgery_id nor doctor_id is present" do
      before do
        allow(controller).to receive(:redirect_back)
          .with(fallback_location: surgeries_path, alert: "Cannot determine doctor or surgery")
          .and_call_original
        request.env["HTTP_REFERER"] = surgeries_path
      end

      it "redirects to surgeries_path" do
        get :index
        expect(response).to redirect_to(surgeries_path)
      end

      it "sets correct flash alert" do
        get :index
        expect(flash[:alert]).to eq("Cannot determine doctor or surgery")
      end
    end
  end
end
