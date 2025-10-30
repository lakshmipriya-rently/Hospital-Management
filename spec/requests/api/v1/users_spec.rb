require "rails_helper"

RSpec.describe "Api::V1::Users", type: :request do
  let!(:user_owner) { create(:user, :patient) }
  let!(:other_user) { create(:user, :patient) }

  let(:owner_token) { create(:doorkeeper_access_token, resource_owner_id: user_owner.id, scopes: "public") }
  let(:other_token) { create(:doorkeeper_access_token, resource_owner_id: other_user.id, scopes: "public") }

  let(:headers_owner) do
    {
      "Authorization" => "Bearer #{owner_token.token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  let(:headers_other) do
    {
      "Authorization" => "Bearer #{other_token.token}",
      "Content-Type" => "application/json",
      "Accept" => "application/json",
    }
  end

  describe "GET /api/v1/users" do
    before { create_list(:user, 3) }

    it "returns all users" do
      get "/api/v1/users", headers: headers_owner
      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(User.count)
    end
  end

  describe "GET /api/v1/users/:id" do
    context "when authorized (matching userable id)" do
      it "returns the user" do
        # create a User whose id equals the current_user_api.userable_id
        target_user = create(:user, id: user_owner.userable_id)
        get "/api/v1/users/#{target_user.id}", headers: headers_owner
        expect(response).to have_http_status(:ok)
        # RABL renders the show as { "user": { ... } }
        expect(json_response["user"]["id"]).to eq(target_user.id)
      end
    end

    context "when accessing another user" do
      it "returns forbidden" do
        target_user = create(:user)
        get "/api/v1/users/#{target_user.id}", headers: headers_other
        expect(response).to have_http_status(:forbidden)
        expect(json_response["error"]).to eq("You're not authorized to do that!")
      end
    end

    context "when user not found" do
      it "returns not found" do
        get "/api/v1/users/999999", headers: headers_owner
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to eq("User not found.")
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
