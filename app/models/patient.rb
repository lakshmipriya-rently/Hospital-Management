class Patient < ApplicationRecord
    has_many :appointments
    has_many :doctors, through: :appointments
    has_many :users, as: :userable
    has_many :bills
    validates :blood_group,:address,:disease,presence:true

    after_create :log_patient_creation

    def log_patient_creation
       Rails.logger.info "New Patient Created #{self.id}"
    end
end
