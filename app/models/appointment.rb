class Appointment < ApplicationRecord
  include Ransackable
  enum status: {
         pending: 0,
         confirmed: 1,
         cancelled: 2,
         completed: 3,
       }

  scope :confirmed, -> { where(status: "confirmed") }
  scope :pending, -> { where(status: "pending") }
                                     
  belongs_to :doctor 
  belongs_to :patient
  belongs_to :surgery, optional: true

  has_one :bill
  has_one :payment, through: :bill

  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_in_the_future

  after_update :create_new_bill
 

  private

  def scheduled_at_must_be_in_the_future
    if scheduled_at.blank?
      errors.add(:scheduled_at, "can't be blank")
    elsif scheduled_at < Time.current
      errors.add(:scheduled_at, "must be in the future")
    end
  end

  def create_new_bill
    @bill = Bill.create(
      appointment: self,
      bill_date: Date.today,
      tot_amount: calculate_total_amount,
      paid_amount: 0,
      is_assigned: true,
    )
    @bill.save
  end

  def calculate_total_amount
    if self.surgery_id.nil?
      return 500
    else
      return 10000
    end
  end
end
