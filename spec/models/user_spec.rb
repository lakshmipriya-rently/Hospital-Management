require "rails_helper"

RSpec.describe User, type: :model do
  describe "devise modules" do
    it "is an instance of User" do
      user = build(:user)
      expect(user).to be_an_instance_of(User)
    end

    it "responds to valid_password?" do
      user = build(:user)
      expect(user).to respond_to(:valid_password?)
    end
  end

  context "validations" do
    subject { FactoryBot.create(:user) }
    it "validates presence of email" do
      user = User.new(email: nil)
      user.validate
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "validates uniqueness of email" do
      FactoryBot.create(:user, email: "user@example.com")
      duplicate = FactoryBot.build(:user, email: "user@example.com")
      duplicate.validate
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "validates length of phone number" do
      user = User.new(phone_no: "12345")
      user.validate
      expect(user.errors[:phone_no]).to include("must be exactly 10 digits")
    end

    it "validates dob cannot be future" do
      user = User.new(dob: Date.today + 1)
      user.validate
      expect(user.errors[:dob]).to include("can't be in the future")
    end

    it "validates the name" do
      user = User.new(name: "lakshmi&")
      user.validate
      expect(user.errors[:name]).to include("should only contain alphabets and spaces")
    end
  end

  context "has_many" do
    it "patients" do
      association = User.reflect_on_association(:patients)
      expect(association.macro).to eq :has_many
    end

    it "doctors" do
      association = User.reflect_on_association(:doctors)
      expect(association.macro).to eq :has_many
    end
  end

  context "callbacks" do
    it "capitalize name" do
      user = FactoryBot.create(:user, name: "lakshmi")
      expect(user.name).to eq("Lakshmi")
    end

    it "set age" do
      user = FactoryBot.create(:user, dob: "10-10-2005")
      expect(user.age).to eq(20)
    end
  end
end
