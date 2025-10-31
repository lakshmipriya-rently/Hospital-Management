require "rails_helper"

RSpec.describe "Api::V1::Doctors", type: :request do
  let(:doctor_user) { create(:user, :doctor) }
  let(:other_doctor_user) { create(:user, :doctor) }

  let(:doctor_token) do
    create(:doorkeeper_access_token, resource_owner_id: doctor_user.id, scopes: "public")
  end

  let(:other_doctor_token) do
    create(:doorkeeper_access_token, resource_owner_id: other_doctor_user.id, scopes: "public")
  end

  let(:headers_doctor) do
    {
      "Authorization" => "Bearer #{doctor_token.token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  let(:headers_other_doctor) do
    {
      "Authorization" => "Bearer #{other_doctor_token.token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  describe "GET /api/v1/doctors" do
    let!(:doctors) { create_list(:doctor, 3) }

    it "returns all doctors" do
      get "/api/v1/doctors", headers: headers_doctor
      expect(json_response.size).to eq(Doctor.count)
    end

    it "returns all doctors" do
      get "/api/v1/doctors", headers: headers_doctor
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /api/v1/doctors/:id" do
    it "returns doctor details if authorized" do
      get "/api/v1/doctors/#{doctor_user.userable.id}", headers: headers_doctor
      expect(response).to have_http_status(:ok)
    end

    it "returns doctor details if authorized" do
      get "/api/v1/doctors/#{doctor_user.userable.id}", headers: headers_doctor
      expect(json_response["id"]).to eq(doctor_user.userable.id)
    end

    it "returns forbidden if accessing another doctor" do
      get "/api/v1/doctors/#{doctor_user.userable.id}", headers: headers_other_doctor
      expect(json_response["error"]).to eq("You're not authorized to do that!")
    end

    it "returns forbidden if accessing another doctor" do
      get "/api/v1/doctors/#{doctor_user.userable.id}", headers: headers_other_doctor
      expect(response).to have_http_status(:forbidden)
    end

    it "returns not found if doctor does not exist" do
      get "/api/v1/doctors/9999", headers: headers_doctor
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found if doctor does not exist" do
      get "/api/v1/doctors/9999", headers: headers_doctor
      expect(json_response["error"]).to eq("Doctor not found.")
    end
  end

  describe "PATCH /api/v1/doctors/:id" do
    let(:valid_params) do
      {
        doctor: {
          available_attributes: {
            start_time: "09:00",
            end_time: "17:00",
            available_days: ["Monday", "Wednesday"],
          },
        },
      }.to_json
    end

    it "updates doctor if authorized" do
      patch "/api/v1/doctors/#{doctor_user.userable.id}", params: valid_params, headers: headers_doctor
      expect(json_response["available_days"]).to include("Monday")
    end

    it "updates doctor if authorized" do
      patch "/api/v1/doctors/#{doctor_user.userable.id}", params: valid_params, headers: headers_doctor
      expect(response).to have_http_status(:ok)
    end

    it "returns forbidden if updating another doctor" do
      patch "/api/v1/doctors/#{doctor_user.userable.id}", params: valid_params, headers: headers_other_doctor
      expect(json_response["error"]).to eq("You're not authorized to do that!")
    end

    it "returns forbidden if updating another doctor" do
      patch "/api/v1/doctors/#{doctor_user.userable.id}", params: valid_params, headers: headers_other_doctor
      expect(response).to have_http_status(:forbidden)
    end

    it "returns unprocessable entity if invalid params" do
      patch "/api/v1/doctors/#{doctor_user.userable.id}",
            params: { doctor: { available_attributes: { start_time: nil } } }.to_json,
            headers: headers_doctor
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end


  describe "PATCH /api/v1/doctors/:id missing params" do
    it "returns bad request when required params are missing" do
      patch "/api/v1/doctors/#{doctor_user.userable.id}",
            params: {}.to_json,
            headers: headers_doctor

      expect(response).to have_http_status(:bad_request)
      expect(json_response["errors"]).to include(/param is missing or the value is empty/)
    end
  end


  def json_response
    JSON.parse(response.body)
  end
end
