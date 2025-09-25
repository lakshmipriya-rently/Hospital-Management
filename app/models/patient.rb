class Patient < ApplicationRecord
    has_many :appointments
    has_many :doctors, through: :appointments
    has_many :bills
    has_many :user, as: :userable, dependent: :destroy


    validates :blood_group, :address,presence: true
end
