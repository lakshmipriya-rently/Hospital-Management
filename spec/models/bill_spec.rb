require 'rails_helper'

RSpec.describe Bill, type: :model do
  context "when validates" do
    subject  { described_class.new(tot_amount: nil, paid_amount: nil) }

    it_behaves_like "presence validation", :tot_amount
    it_behaves_like "presence validation", :paid_amount
  end

  describe "associations" do
    it_behaves_like "has association", :payment, :has_one
    it_behaves_like "has association", :appointment, :belongs_to
  end
end
