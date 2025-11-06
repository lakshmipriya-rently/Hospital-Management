require 'rails_helper'

RSpec.describe Patient, type: :model do
  context "when validates" do
   subject  { described_class.new(blood_group: nil, address: nil) }

    it_behaves_like "presence validation", :blood_group
    it_behaves_like "presence validation", :address
  end

  describe "associations" do
    it_behaves_like "has association", :doctors, :has_many
    it_behaves_like "has association", :bills, :has_many
    it_behaves_like "has association", :appointments, :has_many
    it_behaves_like "has association", :user, :has_one
    it_behaves_like "has association", :surgeries, :has_many

    it "has_many doctors through appointments" do
      association = described_class.reflect_on_association(:doctors)
      expect(association.options[:through]).to eq :appointments
    end

    it "has_many surgeries through appointments" do
      association = described_class.reflect_on_association(:surgeries)
      expect(association.options[:through]).to eq :appointments
    end
  end
end
