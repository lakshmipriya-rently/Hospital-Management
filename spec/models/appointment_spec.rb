require "rails_helper"

RSpec.describe Appointment, type: :model do
  let(:doctor) { create(:doctor, :appointment) }
  let(:patient) { create(:patient, :appointment) }
  let(:appointment) { create(:appointment, doctor: doctor, patient: patient) }

  context "when validates" do
    it "validates scheduled_at presence" do
      appointment = described_class.new(scheduled_at: nil)
      appointment.validate
      expect(appointment.errors[:scheduled_at]).to include("can't be blank")
    end

    it "validates scheduled date must be in future" do
      appointment = described_class.new(scheduled_at: "10-10-2005")
      appointment.validate
      expect(appointment.errors[:scheduled_at]).to include("must be in the future")
    end
  end

  describe "scopes" do
    describe ".confirmed_appointments" do
      it "returns appointments where status is confirmed" do
        confirmed_appointment = create(:appointment, status: "confirmed")
        expect(described_class.confirmed).to include(confirmed_appointment)
      end
    end

    describe ".pending_appointments" do
      it "returns appointments where status is pending" do
        pending_appointment = create(:appointment, status: "pending")
        expect(described_class.pending).to include(pending_appointment)
      end
    end
  end

  describe "associations" do
    it "has_one bill" do
      association = described_class.reflect_on_association(:bill)
      expect(association.macro).to eq :has_one
    end

    it "has_one payment" do
      association = described_class.reflect_on_association(:payment)
      expect(association.macro).to eq :has_one
    end

    it "appointment belongs_to patient" do
      association = described_class.reflect_on_association(:patient)
      expect(association.macro).to eq :belongs_to
    end

    it "appointment belongs_to doctor" do
      association = described_class.reflect_on_association(:doctor)
      expect(association.macro).to eq :belongs_to
    end

    it "belongs_to" do
      association = described_class.reflect_on_association(:surgery)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe "calculate_total_amount (private)" do
    let(:appointment_one) { build(:appointment, surgery_id: nil) }
    let(:surgery) { create(:surgery) }
    let(:appointment_two) { build(:appointment, surgery: surgery) }

    it 'returns 500 when surgery_id is nil' do
      result = appointment_one.send(:calculate_total_amount)
      expect(result).to eq(500)
    end

    it 'returns 10000 when surgery_id is present' do
      result = appointment_two.send(:calculate_total_amount)
      expect(result).to eq(10000)
    end
  end
end
