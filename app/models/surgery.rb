class Surgery < ApplicationRecord
  belongs_to :doctor
  has_many :appointments,dependent: :destroy
  has_many :patients, through: :appointments
  validates :name, presence: true
  validates :description, presence: true
end
