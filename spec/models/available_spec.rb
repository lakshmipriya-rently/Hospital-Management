require 'rails_helper'

RSpec.describe Available, type: :model do
  
  context do "validations"
    before(:each) do
      @available = Available.new(start_time:nil,end_time:nil,available_days:nil)
    end

    it "validates start time" do 
      @available.validate
      expect(@available.errors[:start_time]).to include("can't be blank")
    end
     
    it "validates end time" do
      @available.validate
      expect(@available.errors[:end_time]).to include("can't be blank")
    end
  
    it "validates available day" do 
      @available.validate
      expect(@available.errors[:available_days]).to include("can't be blank")
    end

  end

  context "callbacks" do 
    it "clears available_days before validation" do
      available = build(:available, available_days: [])
      available.valid? 
      expect(available.available_days).to eq([])
    end
  end

  describe "associations" do
    it "belongs_to doctor" do
      association =  Available.reflect_on_association(:doctor)
      expect(association.macro).to eq :belongs_to
    end 
  end
    
end
