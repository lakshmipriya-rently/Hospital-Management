class User < ApplicationRecord
    belongs_to :userable,polymorphic: true,optional: true
    validates :name,:dob,presence: true
    validates :phone_no, length: { is: 10, message: "must be exactly 10 digits" }

    before_save :clean_phone_number
    before_save :set_age 
    after_create :log_user_creation

    validate :dob_cannot_be_in_future

    private
    def dob_cannot_be_in_future
        return if dob.blank?

        if dob > Date.today
            errors.add(:dob, "can't be in the future")
        end
    end

    def set_age
        return unless dob.present?
       today = Date.today
       self.age = today.year - dob.year
       self.age -= 1 if dob.to_date.change(year: today.year) > today
   end

    def clean_phone_number
    self.phone_no = phone_no.gsub(/\D/, '') if phone_no.present?
    end

    def log_user_creation
      Rails.logger.info "New user created: #{name} (ID: #{id}, Role: #{userable_type})"
    end

end
