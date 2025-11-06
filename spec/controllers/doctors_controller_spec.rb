require 'rails_helper'

RSpec.describe DoctorsController, type: :controller do
  let!(:doctor) { create(:doctor) }
  let!(:available) { create(:available, doctor: doctor) }

  let!(:appointment_two) { create(:appointment, doctor: doctor, scheduled_at: 1.day.from_now) }

  let!(:appointment_one) do
    appointment = build(:appointment, doctor: doctor, patient: create(:patient), scheduled_at: 1.day.ago, status: :cancelled)
    appointment.save(validate: false)
    appointment
  end


  describe "GET #index" do
    before { get :index }

    it "assigns all doctors to @doctors" do
      expect(assigns(:doctors)).to include(doctor)
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before { get :show, params: { id: doctor.id } }

    it "assigns the requested doctor to @doctor" do
      expect(assigns(:doctor)).to eq(doctor)
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #edit" do
    context "when available record exists" do
      before { get :edit, params: { id: doctor.id } }

      it "does not build a new available" do
        expect(assigns(:doctor).available).to eq(available)
      end
    end

    context "when available record is missing" do
      let!(:new_doctor) { create(:doctor, available: nil) }

      before { get :edit, params: { id: new_doctor.id } }

      it "builds a new available record" do
        expect(assigns(:doctor).available).to be_a_new(Available)
      end
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      let(:valid_params) do
        {
          id: doctor.id,
          doctor: {
            available_attributes: {
              start_time: "09:00",
              end_time: "17:00",
              is_active: true,
              available_days: [ "monday" ]
            }
          }
        }
      end

      before { patch :update, params: valid_params }

      it "updates the doctor’s availability" do
        expect(doctor.reload.available.start_time.strftime("%H:%M")).to eq("09:00")
      end

      it "redirects to the doctor show page" do
        expect(response).to redirect_to(doctor_path(doctor))
      end

      it "sets a success notice" do
        expect(flash[:notice]).to eq("Doctor Available Updated Successfully")
      end
    end

    context "with invalid params" do
      before do
        patch :update, params: { id: doctor.id, doctor: { available_attributes: { start_time: nil } } }
      end

      it "renders the edit template" do
        expect(response).to render_template(:edit)
      end

      it "returns unprocessable entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "private method check_if_appointment_expired" do
    before { get :show, params: { id: doctor.id } }

    it "cancels past appointments" do
      expect(appointment_one.reload.status).to eq("cancelled")
    end

    it "does not cancel future appointments" do
      expect(appointment_two.reload.status).not_to eq("cancelled")
    end
  end
end
