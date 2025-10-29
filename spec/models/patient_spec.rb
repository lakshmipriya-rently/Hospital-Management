require 'rails_helper'

RSpec.describe Patient, type: :model do
  
  context "validations" do
    
    before(:each) do
      @patient = Patient.new(blood_group:nil,address:nil)
    end
    
    it "validates blood_group presence" do
      @patient.validate
      expect(@patient.errors[:blood_group]).to include("can't be blank")
    end

    it "validates address presence" do 
      @patient.validate
      expect(@patient.errors[:blood_group]).to include("can't be blank")
    end
  end 

  describe "associations" do
    it "has_many doctors" do
      association = Patient.reflect_on_association(:doctors)
      expect(association.macro).to eq :has_many
    end

    it "has_many doctors through appointments" do
      association = Patient.reflect_on_association(:doctors)
      expect(association.options[:through]).to eq :appointments
    end
    
    it "has_many bills" do
      association = Patient.reflect_on_association(:bills)
      expect(association.macro).to eq :has_many
    end

    it "has_many appontments" do
      association = Patient.reflect_on_association(:appointments)
      expect(association.macro).to eq :has_many
    end
     
    it "has_one user" do
      association = Patient.reflect_on_association(:user)
      expect(association.macro).to eq :has_one
    end

    it "has_many surgeries" do
      association = Patient.reflect_on_association(:surgeries)
      expect(association.macro).to eq :has_many
    end

    it "has_many surgeries through appointments" do
      association = Patient.reflect_on_association(:surgeries)
      expect(association.options[:through]).to eq :appointments
    end
  end
end


