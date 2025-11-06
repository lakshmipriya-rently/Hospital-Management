require 'rails_helper'

RSpec.describe Available, type: :model do
  context "when validates" do
    subject { described_class.new(start_time: nil, end_time: nil, available_days: nil) }

    let(:available) { described_class.new(start_time: nil, end_time: nil, available_days: nil) }

     it_behaves_like "presence validation", :start_time
     it_behaves_like "presence validation", :end_time

    it "validates available day" do
      available.validate
      expect(available.errors[:available_days]).to include("can't be blank")
    end
  end

  context "when callbacks" do
    it "clears available_days before validation" do
      available = build(:available, available_days: [])
      available.valid?
      expect(available.available_days).to eq([])
    end
  end

  describe "associations" do
    it "belongs_to doctor" do
      association =  described_class.reflect_on_association(:doctor)
      expect(association.macro).to eq :belongs_to
    end
  end
end
