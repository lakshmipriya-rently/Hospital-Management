class User < ApplicationRecord
    belongs_to :userable,polymorphic: true,optional: true
    validates :name,:email,:age,:dob,presence: true
    validates :phone_no, length: { is: 10, message: "must be exactly 10 digits" }

    before_validation :normalize_email

    before_save :clean_phone_number
   
    after_create :log_user_creation

    validate :dob_cannot_be_in_future

    private
    def dob_cannot_be_in_future
        return if dob.blank?

        if dob > Date.today
            errors.add(:dob, "can't be in the future")
        end
    end



    def age_must_match_dob
       return if dob.blank? || age.blank?

       calc_age = ((Date.today - dob).to_i / 365)
       if age.to_i != calc_age
           errors.add(:age, "does not match the date of birth")
       end
    end

    
    def clean_phone_number
    self.phone_no = phone_no.gsub(/\D/, '') if phone_no.present?
    end

    def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
    end

    def log_user_creation
      Rails.logger.info "New user created: #{name} (ID: #{id}, Role: #{userable_type})"
    end
 
end
