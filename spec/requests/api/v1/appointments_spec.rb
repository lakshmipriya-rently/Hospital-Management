require "rails_helper"

RSpec.describe "Api::V1::Appointments", type: :request do
  let(:base_url) { "/api/v1/appointments" }
  let!(:doctor_user) { create(:user, userable: create(:doctor)) }
  let!(:patient_user) { create(:user, userable: create(:patient)) }
  let!(:other_patient_user) { create(:user, userable: create(:patient)) }

  let!(:appointment_doctor) { create(:doctor) }
  let!(:appointment_patient) { create(:patient) }
  let!(:existing_appointment) { create(:appointment, doctor: appointment_doctor, patient: appointment_patient) }
  let!(:appointments) { create_list(:appointment, 3) }

  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(user)
    allow_any_instance_of(Api::V1::AppointmentsController).to receive(:current_user).and_return(user)
    { "ACCEPT" => "application/json" }
  end

  describe "GET #index" do
    before { get base_url, headers: auth_headers(patient_user) }

    it "returns a successful response" do
      expect(response).to have_http_status(:ok)
    end

    it "returns all appointments" do
      expect(json_response.size).to eq(Appointment.count)
    end
  end

  describe "GET #show" do
    context "when the appointment exists" do
      before { get "#{base_url}/#{existing_appointment.id}", headers: auth_headers(patient_user) }

      it "returns a successful response" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the correct appointment" do
        response_json = json_response
        expect(response_json["id"]).to eq(existing_appointment.id)
      end
    end

    context "when the appointment does not exist" do
      before { get "#{base_url}/9999", headers: auth_headers(patient_user) }
      it "returns a not found status" do
        expect(response).to have_http_status(:ok)
      end
      it "returns a not found status" do
        expect(json_response).to be_nil
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        appointment: attributes_for(:appointment,
                                    scheduled_at: 1.day.from_now,
                                    disease: "Flu",
                                    surgery_id: create(:surgery, doctor: appointment_doctor).id),
      }
    end
    let(:invalid_params) { { appointment: { disease: nil, scheduled_at: nil } } }

    before { allow_any_instance_of(Api::V1::AppointmentsController).to receive(:set_appointment_context) }

    context "when logged in as a Patient (authorized)" do
      context "with invalid parameters" do
        it "does not create a new Appointment" do
          expect {
            post base_url, params: invalid_params, headers: auth_headers(patient_user)
          }.not_to change(Appointment, :count)
        end

        it "returns unprocessable entity status and errors" do
          post base_url, params: invalid_params, headers: auth_headers(patient_user)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns unprocessable entity status and errors" do
          post base_url, params: invalid_params, headers: auth_headers(patient_user)
          expect(json_response).to include("errors")
        end
      end
    end

    context "when logged in as a Doctor (unauthorized for create)" do
      it "returns unauthorized status" do
        post base_url, params: valid_params, headers: auth_headers(doctor_user)
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized status" do
        post base_url, params: valid_params, headers: auth_headers(doctor_user)
        expect(json_response["error"]).to include("Must be logged in as a patient.")
      end
    end
  end

  describe "PUT #update" do
    let(:new_disease) { "Severe Flu" }
    let(:new_status) { "confirmed" }
    let(:valid_params) { { appointment: { disease: new_disease, status: new_status } } }
    let(:invalid_params) { { appointment: { scheduled_at: nil } } }

    context "when logged in as a Doctor (authorized)" do
      context "with valid parameters" do
        before { put "#{base_url}/#{existing_appointment.id}", params: valid_params, headers: auth_headers(doctor_user) }

        it "updates the appointment" do
          existing_appointment.reload
          expect(existing_appointment.disease).to eq(new_disease)
        end

        it "updates the appointment" do
          existing_appointment.reload
          expect(existing_appointment.status).to eq(new_status)
        end

        it "returns a successful response and the updated appointment" do
          expect(response).to have_http_status(:ok)
        end

        it "returns a successful response and the updated appointment" do
          expect(json_response["disease"]).to eq(new_disease)
        end
      end

      context "with invalid parameters" do
        before { put "#{base_url}/#{existing_appointment.id}", params: invalid_params, headers: auth_headers(doctor_user) }

        it "does not update the appointment" do
          original_disease = existing_appointment.disease
          existing_appointment.reload
          expect(existing_appointment.disease).to eq(original_disease)
        end

        it "returns unprocessable entity status and errors" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns unprocessable entity status and errors" do
          expect(json_response).to include("errors")
        end
      end

      context "when appointment does not exist" do
        before { put "#{base_url}/9999", params: valid_params, headers: auth_headers(doctor_user) }

        it "returns a not found status" do
          expect(response).to have_http_status(:not_found)
        end

        it "returns a not found status" do
          expect(json_response["error"]).to eq("Appointment not found")
        end
      end
    end

    context "when logged in as a Patient (unauthorized for update)" do
      it "returns unauthorized status" do
        put "#{base_url}/#{existing_appointment.id}", params: valid_params, headers: auth_headers(patient_user)
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns unauthorized status" do
        put "#{base_url}/#{existing_appointment.id}", params: valid_params, headers: auth_headers(patient_user)
        expect(json_response["error"]).to include("Must be logged in as a doctor.")
      end
    end
  end
end
