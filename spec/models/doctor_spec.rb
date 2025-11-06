require "rails_helper"

RSpec.describe Doctor, type: :model do
  describe "associations" do
    it_behaves_like "has association", :available, :has_one
    it_behaves_like "has association", :user, :has_one
    it_behaves_like "has association", :appointments, :has_many
    it_behaves_like "has association", :surgeries, :has_many
    it_behaves_like "has association", :patients, :has_many
    it_behaves_like "has association", :specializations, :has_and_belongs_to_many
  end

  context "when validates" do
    subject { described_class.new(license_id: nil, experience: nil, type_of_degree: nil, salary: nil) }

    it_behaves_like "presence validation", :license_id
    it_behaves_like "presence validation", :experience
    it_behaves_like "presence validation", :type_of_degree
    it_behaves_like "presence validation", :salary
  end

  context "when callbacks" do
    it "normalize license id before save" do
      doctor = FactoryBot.create(:doctor, license_id: "dOcTor@2025")
      expect(doctor.license_id).to eq("DOCTOR@2025")
    end
  end

  describe "active_now?" do
    let(:doctor) { create(:doctor) }

    it "returns false if doctor is not active (outside working hours)" do
      available = create(:available, doctor: doctor, start_time: 2.hours.ago, end_time: 1.hour.ago)
      doctor.reload
      expect(doctor.active_now?).to be(false)
    end

    it "returns true if doctor is currently active" do
      create(:available, doctor: doctor, start_time: "09:15", end_time: "18:00")
      doctor.reload
      expect(doctor.active_now?).to be(true)
    end
  end

  describe "scopes" do
    describe ".active_now" do
      it "returns doctors whose available time does not include now" do
        active_doctor = create(:doctor)
        create(:available, doctor: active_doctor, start_time: 2.hours.ago, end_time: 1.hour.ago)
        expect(described_class.active_now).to include(active_doctor)
      end
    end

    describe ".inactive_now" do
      it "returns doctors whose available time includes now" do
        inactive_doctor = create(:doctor)
        create(:available, doctor: inactive_doctor, start_time: 1.hour.ago, end_time: 1.hour.from_now)
        expect(described_class.inactive_now).to include(inactive_doctor)
      end
    end
  end
end
