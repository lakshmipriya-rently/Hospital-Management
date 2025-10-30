require "rails_helper"

RSpec.describe "Api::V1::Surgeries", type: :request do
  let(:doctor_profile) { create(:doctor) }
  let(:doctor_user) { create(:user, userable: doctor_profile) }
  let(:other_doctor_profile) { create(:doctor) }
  let(:other_doctor_user) { create(:user, userable: other_doctor_profile) }
  let(:patient_profile) { create(:patient) }
  let(:patient_user) { create(:user, userable: patient_profile) }

  before do
    allow_any_instance_of(Api::V1::SurgeriesController).to receive(:doorkeeper_authorize!).and_return(true)
    allow_any_instance_of(Api::V1::SurgeriesController).to receive(:authenticate_user!).and_return(true)
  end

  describe "GET /api/v1/surgeries" do
    before do
      create_list(:surgery, 2, doctor: doctor_profile)
      allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(doctor_user)
      get "/api/v1/surgeries"
    end

    it "returns all surgeries" do
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "GET /api/v1/surgeries/:id" do
    let(:surgery) { create(:surgery, doctor: doctor_profile) }

    before do
      allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(doctor_user)
    end

    it "returns the surgery when it exists" do
      get "/api/v1/surgeries/#{surgery.id}"
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(surgery.id)
    end

    it "returns not_found when surgery does not exist" do
      get "/api/v1/surgeries/0"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/surgeries" do
    let(:valid_params) do
      {
        surgery: {
          name: "Appendectomy",
          description: "Removal of appendix",
          doctor_id: doctor_profile.id,
        },
      }
    end

    context "when current user is a doctor" do
      before do
        allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(doctor_user)
      end

      it "creates a surgery" do
        expect {
          post "/api/v1/surgeries", params: valid_params
        }.to change(Surgery, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context "when current user is not a doctor" do
      before do
        allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(patient_user)
      end

      it "returns forbidden" do
        post "/api/v1/surgeries", params: valid_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/surgeries/:id" do
    let!(:surgery) { create(:surgery, doctor: doctor_profile) }

    context "when doctor owns the surgery" do
      before do
        allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(doctor_user)
      end

      it "deletes the surgery" do
        expect {
          delete "/api/v1/surgeries/#{surgery.id}"
        }.to change(Surgery, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when another doctor tries to delete" do
      before do
        allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(other_doctor_user)
      end

      it "returns forbidden" do
        delete "/api/v1/surgeries/#{surgery.id}"
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/surgeries/:id/book_appointment" do
    let(:surgery) { create(:surgery, doctor: doctor_profile) }

    context "when current user is not a patient" do
      before do
        allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(doctor_user)
        post "/api/v1/surgeries/#{surgery.id}/book_appointment"
      end

      it "returns not_found" do
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when current user is a patient" do
      before do
        allow_any_instance_of(Api::V1::SurgeriesController).to receive(:current_user).and_return(patient_user)
        post "/api/v1/surgeries/#{surgery.id}/book_appointment"
      end

      it "does not return forbidden (allows patient flow)" do
        expect(response).not_to have_http_status(:forbidden)
      end
    end
  end
end
