require 'rails_helper'

RSpec.describe Bill, type: :model do

   context "validates" do
    before(:each) do
       @bill = Bill.new(tot_amount:nil,paid_amount:nil)
    end

    it "validates tot_amount presence" do
       @bill.validate
       expect(@bill.errors[:tot_amount]).to include("can't be blank")
    end

    it "validates paid_amount presence" do
      @bill.validate
      expect(@bill.errors[:tot_amount]).to include("can't be blank")
    end
   end

   describe "associations" do
      it "has_one payment" do
        association = Bill.reflect_on_association(:payment)
        expect(association.macro).to eq :has_one
      end

      it "belongs_to patient" do
        association = Bill.reflect_on_association(:appointment)
        expect(association.macro).to eq :belongs_to
      end
   end


end
 