class User < ApplicationRecord
 
  include Ransackable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable, :registerable
  belongs_to :userable, polymorphic: true, optional: true

  has_many :doctors
  has_many :patients
 
  validates :phone_no,presence: true, length: { is: 10, message: "must be exactly 10 digits" }
  validate :dob_cannot_be_in_future
  validate :name_should_not_have_other_char

  before_save :capitalize_name, :set_age

  private

  def dob_cannot_be_in_future
    if dob.blank?
      errors.add(:dob, "please enter DOB")
    elsif dob > Date.today
      errors.add(:dob, "can't be in the future")
    end
  end

  def set_age
    return unless dob.present?
    today = Date.today
    self.age = today.year - dob.year
    year = today.year
    month = dob.month
    day = dob.day  
    birthday_this_year = Date.new(year, month, day)
  
    self.age -= 1 if birthday_this_year > today
  end

  
  def name_should_not_have_other_char
    if name.present? && name !~ /\A[a-zA-Z\s]+\z/
      errors.add(:name, "should only contain alphabets and spaces")
    end
  end

  def capitalize_name
    self.name = name.titleize
  end
end
