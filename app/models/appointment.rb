class Appointment < ApplicationRecord
  enum status: {
  pending: 0,
  confirmed: 1,
  cancelled: 2,
  completed: 3
}

  belongs_to :doctor
  belongs_to :patient

  has_one :bill
  has_one :payment, through: :bill

  validates :appointment_date, :appointment_time, presence: true
  validate :appointment_date_must_be_in_the_future


  private

  def appointment_date_must_be_in_the_future
     if appointment_date.blank?
       errors.add(:appointment_date, "can't be blank")
     elsif appointment_date < Date.today
       errors.add(:appointment_date, "must be in the future")
     end
  end

end
