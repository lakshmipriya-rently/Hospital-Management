require "rails_helper"

RSpec.describe Doctor, type: :model do
  describe "associations" do
    it "has_one available" do
      association = Doctor.reflect_on_association(:available)
      expect(association.macro).to eq :has_one
    end

    it "has_one user" do
      association = Doctor.reflect_on_association(:user)
      expect(association.macro).to eq :has_one
    end

    it "has_many appointment option dependent and destroy" do
      association = Doctor.reflect_on_association(:appointments)
      expect(association.macro).to eq :has_many
    end

    it "has_many surgeries" do
      association = Doctor.reflect_on_association(:surgeries)
      expect(association.macro).to eq :has_many
    end

    it "has_many patients through apponitments" do
      association = Doctor.reflect_on_association(:patients)
      expect(association.macro).to eq :has_many
    end

    it "has_and_belongs_to_many specialization" do
      association = Doctor.reflect_on_association(:specializations)
      expect(association.macro).to eq :has_and_belongs_to_many
    end
  end

  context "validations" do
    before(:each) do
      @doctor = Doctor.new(license_id: nil, experience: nil, type_of_degree: nil, salary: nil)
    end

    it "validates license_id presence" do
      @doctor.validate
      expect(@doctor.errors[:license_id]).to include("can't be blank")
    end

    it "validates experience presence" do
      @doctor.validate
      expect(@doctor.errors[:experience]).to include("can't be blank")
    end

    it "validates degree presence" do
      @doctor.validate
      expect(@doctor.errors[:type_of_degree]).to include("can't be blank")
    end

    it "validates salary presence" do
      @doctor.validate
      expect(@doctor.errors[:salary]).to include("can't be blank")
    end
  end

  context "callbacks" do
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
      expect(doctor.active_now?).to eq(false)
    end

    it "returns true if doctor is currently active" do
      create(:available, doctor: doctor, start_time: "09:15", end_time: "18:30")
      doctor.reload
      expect(doctor.active_now?).to eq(true)
    end
  end

  describe "scopes" do
    describe ".active_now" do
      it "returns doctors whose available time does not include now" do
        active_doctor = create(:doctor)
        create(:available, doctor: active_doctor, start_time: 2.hours.ago, end_time: 1.hour.ago)
        expect(Doctor.active_now).to include(active_doctor)
      end
    end

    describe ".inactive_now" do
      it "returns doctors whose available time includes now" do
        inactive_doctor = create(:doctor)
        create(:available, doctor: inactive_doctor, start_time: 1.hour.ago, end_time: 1.hour.from_now)
        expect(Doctor.inactive_now).to include(inactive_doctor)
      end
    end
  end
end
