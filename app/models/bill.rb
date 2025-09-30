class Bill < ApplicationRecord
   
    include Ransackable
    belongs_to :appointment
    has_one :payment
    validates :tot_amount, :paid_amount, presence: true, comparison: { greater_than: 0 }
    before_validation :bill_date_must_be_equal_to_today

   def bill_date_must_be_equal_to_today
     if bill_date.blank?
       errors.add(:bill_date, "can't be blank")
     elsif bill_date < Date.today
       errors.add(:bill_date, "can't be past")
     end
  end
end
