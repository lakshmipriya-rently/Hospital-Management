class Bill < ApplicationRecord
  include Ransackable
  belongs_to :appointment
  has_one :payment
  validates :tot_amount, :paid_amount, presence: true, comparison: { greater_than: -1 }
end
