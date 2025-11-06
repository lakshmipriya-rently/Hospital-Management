require "rails_helper"

RSpec.describe PatientsController, type: :controller do
  let!(:patient) { create(:patient) }

  describe "GET #index" do
    before { get :index }

    it "assigns all patients to @patients" do
      expect(assigns(:patients)).to include(patient)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before { get :show, params: { id: patient.id } }

    it "assigns the requested patient to @patient" do
      expect(assigns(:patient)).to eq(patient)
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end

    context "when unauthenticated" do
      before { get :show, params: { id: 9999 } }

      it "redirects to the unauthenticated root path" do
        expect(response).to redirect_to(unauthenticated_root_path)
      end
    end
  end

  describe "GET #edit" do
    before { get :edit, params: { id: patient.id } }

    it "does not build a new available" do
      expect(assigns(:patient)).to eq(patient)
    end

    it "renders the edit template" do
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:valid_params) do
        {
          id: patient.id,
          patient: {
            address: "Eachanari,Coimbatore",
            blood_group: "O+"
          }
        }
      end

      before { patch :update, params: valid_params }

      it "updates the patient’s blood_group" do
        expect(patient.reload.blood_group).to eq("O+")
      end

      it "updates the patient's address" do
        expect(patient.reload.address).to eq("Eachanari,Coimbatore")
      end

      it "redirects to the patient show page" do
        expect(response).to redirect_to(patient_path(patient))
      end

      it "sets a success notice" do
        expect(flash[:notice]).to eq("Profile Updated")
      end
    end

    context "with invalid params" do
      before do
        patch :update, params: { id: patient.id, patient: { blood_group: nil } }
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET #confirmed" do
    before { get :confirmed, params: { id: patient.id } }

    it "assigns confirmed appointments to @appointments" do
      confirmed = create(:appointment, patient: patient, status: :confirmed)
      expect(assigns(:appointments)).to include(confirmed)
    end
  end

  describe "private method check_and_update_status" do
    before { get :show, params: { id: patient.id } }

    it "updates payment status to paid" do
      bill = create(:bill, appointment: create(:appointment, patient: patient))
      payment = create(:payment, bill: bill, status: :pending)
      bill.update(paid_amount: bill.tot_amount)
      get :show, params: { id: patient.id }
      expect(payment.reload.status).to eq("paid")
    end

    it "updates payment status to un_paid" do
      bill = create(:bill, appointment: create(:appointment, patient: patient))
      payment = create(:payment, bill: bill, status: :pending)
      bill.update(paid_amount: 1)
      get :show, params: { id: patient.id }
      expect(payment.reload.status).to eq("un_paid")
    end

    it "updates payment status to pending" do
      bill = create(:bill, appointment: create(:appointment, patient: patient))
      payment = create(:payment, bill: bill, status: :pending)
      bill.update(paid_amount: bill.tot_amount - 50)
      get :show, params: { id: patient.id }
      expect(payment.reload.status).to eq("pending")
    end
  end
end
