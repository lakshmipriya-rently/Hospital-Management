require "rails_helper"

RSpec.describe "Api::V1::Homes", type: :request do
  describe "GET /home/redirect_by_role" do
    it "redirects doctor to doctor path" do
      doctor_user = create(:user, :doctor)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(doctor_user)
      get home_redirect_by_role_path
      expect(response).to redirect_to(doctor_path(doctor_user.userable))
    end

    it "redirects patient to patient path" do
      patient_user = create(:user, :patient)
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(patient_user)
      get home_redirect_by_role_path
      expect(response).to redirect_to(patient_path(patient_user.userable))
    end

    it "redirects unauthenticated users to unauthenticated root path" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      get home_redirect_by_role_path
      expect(response).to redirect_to(unauthenticated_root_path)
    end
  end
end
