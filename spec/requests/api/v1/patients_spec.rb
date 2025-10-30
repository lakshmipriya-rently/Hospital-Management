require "rails_helper"

RSpec.describe "Api::V1::Patients", type: :request do
  let(:patient_user) { create(:user, :patient) }
  let(:other_patient_user) { create(:user, :patient) }

  def json_response
    JSON.parse(response.body)
  end

  let(:patient_token) do
    create(:doorkeeper_access_token, resource_owner_id: patient_user.id, scopes: "public")
  end

  let(:other_patient_token) do
    create(:doorkeeper_access_token, resource_owner_id: other_patient_user.id, scopes: "public")
  end

  let(:headers_patient) do
    {
      "Authorization" => "Bearer #{patient_token.token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  let(:headers_other_patient) do
    {
      "Authorization" => "Bearer #{other_patient_token.token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  describe "GET /api/v1/patients" do
    let!(:patients) { create_list(:patient, 3) }
    it "returns all patients" do
      get "/api/v1/patients", headers: headers_patient
      expect(response).to have_http_status(:ok)
    end

    it "returns all patients" do
      get "/api/v1/patients", headers: headers_patient
      expect(json_response.size).to eq(Patient.count)
    end
  end

  describe "GET /api/v1/patients/:id" do
    it "returns forbidden if accessing another patient" do
      get "/api/v1/patients/#{patient_user.userable.id}", headers: headers_other_patient
      expect(response).to have_http_status(:forbidden)
    end

    it "returns forbidden if accessing another patient" do
      get "/api/v1/patients/#{patient_user.userable.id}", headers: headers_other_patient
      expect(json_response["error"]).to include("You're not authorized to do that!")
    end

    it "returns patient details if authorized" do
      get "/api/v1/patients/#{patient_user.userable.id}", headers: headers_patient
      expect(response).to have_http_status(:ok)
    end

    it "returns patient details if authorized" do
      get "/api/v1/patients/#{patient_user.userable.id}", headers: headers_patient
      expect(json_response["patient"]["id"]).to eq(patient_user.userable.id)
    end

    it "returns not found if patient does not exist" do
      get "/api/v1/patients/9999", headers: headers_patient
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found if patient does not exist" do
      get "/api/v1/patients/9999", headers: headers_patient
      expect(json_response["error"]).to include("Patient not found.")
    end
  end

  describe "PATCH /api/v1/patients/:id" do
    let(:valid_params) do
      {
        patient: {
          blood_group: "O+",
          address: "eachanari,coimbatore",
        },
      }.to_json
    end

    it "updates patient if authorized" do
      patch "/api/v1/patients/#{patient_user.userable.id}", params: valid_params, headers: headers_patient
      expect(response).to have_http_status(:ok)
    end

    it "updates patient if authorized" do
      patch "/api/v1/patients/#{patient_user.userable.id}", params: valid_params, headers: headers_patient
      expect(json_response["patient"]["blood_group"]).to eq("O+")
    end

    it "returns forbidden if updating another patient" do
      patch "/api/v1/patients/#{patient_user.userable.id}", params: valid_params, headers: headers_other_patient
      expect(response).to have_http_status(:forbidden)
    end

    it "returns forbidden if updating another patient" do
      patch "/api/v1/patients/#{patient_user.userable.id}", params: valid_params, headers: headers_other_patient
      expect(json_response["error"]).to include("You're not authorized to do that!")
    end

    it "returns unprocessable entity if invalid params" do
      patch "/api/v1/patients/#{patient_user.userable.id}",
            params: { patient: { blood_group: nil } }.to_json,
            headers: headers_patient
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/patients/:id/confirmed" do
    let!(:confirmed_appointment) do
      create(:appointment, patient: patient_user.userable, status: "confirmed")
    end

    it "returns confirmed appointments for authorized patient" do
      get "/api/v1/patients/#{patient_user.userable.id}/confirmed", headers: headers_patient
      expect(response).to have_http_status(:ok)
    end

    it "returns confirmed appointments for authorized patient" do
      get "/api/v1/patients/#{patient_user.userable.id}/confirmed", headers: headers_patient
      expect(json_response["appointments"]).to be_an(Array)
    end

    it "returns confirmed appointments for authorized patient" do
      get "/api/v1/patients/#{patient_user.userable.id}/confirmed", headers: headers_patient
      expect(json_response["appointments"].first["status"]).to eq("confirmed")
    end

    it "returns forbidden if accessing another patient's confirmed appointments" do
      get "/api/v1/patients/#{patient_user.userable.id}/confirmed", headers: headers_other_patient
      expect(response).to have_http_status(:forbidden)
    end

    it "returns forbidden if accessing another patient's confirmed appointments" do
      get "/api/v1/patients/#{patient_user.userable.id}/confirmed", headers: headers_other_patient
      expect(json_response["error"]).to include("You can't access other records")
    end
  end
end
