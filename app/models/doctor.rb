class Doctor < ApplicationRecord
    has_one :available
    has_many :appointments
    has_many :users, as: :userable
    has_many :patients, through: :appointments
    has_and_belongs_to_many :specializations
    accepts_nested_attributes_for :specializations, allow_destroy: true
    accepts_nested_attributes_for :available
    validates :license_id,:experience,:type_of_degree,:salary,presence: true

    before_save :normalize_license_id
    after_create :log_doctor_creation

    private

    def log_doctor_creation
      Rails.logger.info "New doctor created: #{self.license_id} (#{self.id})"
    end

    

    def normalize_license_id
        self.license_id = license_id.strip.upcase if license_id.present?
    end

end
