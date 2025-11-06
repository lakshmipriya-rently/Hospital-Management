class Doctor < ApplicationRecord
  include Ransackable
  has_one :available
  has_many :appointments, dependent: :destroy
  has_many :surgeries
  has_one :user, as: :userable
  has_many :patients, through: :appointments
  has_and_belongs_to_many :specializations
  accepts_nested_attributes_for :specializations, allow_destroy: true
  accepts_nested_attributes_for :available, update_only: true
  validates :license_id, :experience, :type_of_degree, :salary, presence: true

  before_save :normalize_license_id

  scope :active_now, -> {
          joins(:available).where.not(
            "availables.start_time <= ? AND availables.end_time >= ?",
            Time.current.strftime("%H:%M"),
            Time.current.strftime("%H:%M")
          )
  }

  scope :inactive_now, -> {
          joins(:available).where(
            "availables.start_time <= ? AND availables.end_time >= ?",
            Time.current.strftime("%H:%M"),
            Time.current.strftime("%H:%M")
          )
        }

  def active_now?
    return false unless available&.start_time.present? && available&.end_time.present?
    now = Time.now.strftime("%H:%M")
    start_str = available.start_time.strftime("%H:%M")
    end_str = available.end_time.strftime("%H:%M")
    now >= start_str && now <= end_str
  end

  private
  def normalize_license_id
    self.license_id = license_id.strip.upcase if license_id.present?
  end
end
