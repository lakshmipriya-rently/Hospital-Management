class Appointment < ApplicationRecord
  include Ransackable
  enum status: {
  pending: 0,
  confirmed: 1,
  cancelled: 2,
  completed: 3
}
  
  scope :confirmed, ->{where(status: "confirmed")}
  scope :pending, ->{where(status: "pending")}

  belongs_to :doctor
  belongs_to :patient

  has_one :bill
  has_one :payment, through: :bill

  validates :scheduled_at, presence: true
  validate :scheduled_at_must_be_in_the_future



  private

  def scheduled_at_must_be_in_the_future
  if scheduled_at.blank?
    errors.add(:scheduled_at, "can't be blank")
  elsif scheduled_at < Time.current
    errors.add(:scheduled_at, "must be in the future")
  end
end


end
