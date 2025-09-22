
class Available < ApplicationRecord
  belongs_to :doctor

  before_validation :clean_available_days

  validates :available_days, :start_time, :end_time, presence: true

  def clean_available_days
    self.available_days = (available_days || []).reject(&:blank?)
  end
end
