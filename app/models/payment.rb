class Payment < ApplicationRecord
  include Ransackable
  enum status: {
         pending: 0,
         paid: 1,
         un_paid: 2,
       } 

  belongs_to :bill

  after_create :update_payment_status
  validate :cannot_overpay

  scope :un_paid, -> { where(status: Payment.statuses[:un_paid]) }
  scope :paid, -> { where(status: Payment.statuses[:paid]) }



  private

  def cannot_overpay
    return if bill.nil? || amount_to_be_paid.nil?
    if (bill.paid_amount + amount_to_be_paid) > bill.tot_amount
      errors.add(:amount_to_be_paid, "cannot be greater than the remaining bill amount")
    end
  end

  def update_payment_status
    return if bill.nil? || amount_to_be_paid.nil?
    bill.paid_amount += amount_to_be_paid
    bill.save if bill.changed?
  end
end
