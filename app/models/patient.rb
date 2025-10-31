class Patient < ApplicationRecord
  include Ransackable

  has_many :appointments, dependent: :destroy
  has_many :doctors, through: :appointments
  has_many :bills
  has_one :user, as: :userable, dependent: :nullify
  has_many :surgeries, through: :appointments
  accepts_nested_attributes_for :user

  validates :blood_group, :address, presence: true
  
end
