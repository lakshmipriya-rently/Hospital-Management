require 'rails_helper'

RSpec.describe Surgery, type: :model do
  describe 'associations' do
    it "has_many patients" do
      association = Surgery.reflect_on_association(:patients)
      expect(association.macro).to eq :has_many
    end 

    it "has_many appointments" do
       association = Surgery.reflect_on_association(:appointments)
      expect(association.macro).to eq :has_many
    end

    it "belongs_to doctor" do
      association = Surgery.reflect_on_association(:doctor)
      expect(association.macro).to eq :belongs_to
    end 
  end
end
