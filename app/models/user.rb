class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    belongs_to :userable, polymorphic: true, optional: true


    validates :phone_no, length: { is: 10, message: "must be exactly 10 digits" }
    validate :dob_cannot_be_in_future
    validate :name_should_not_have_other_char


    before_save :capitalize_name, :clean_phone_number, :set_age
    after_create :log_user_creation


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
       self.age -= 1 if dob.to_date.change(year: today.year) > today
   end

    def clean_phone_number
    self.phone_no = phone_no.gsub(/\D/, "") if phone_no.present?
    end

    def log_user_creation
      Rails.logger.info "New user created: #{name} (ID: #{id}, Role: #{userable_type})"
    end

    def name_should_not_have_other_char
         if name.present? && name !~ /\A[a-zA-Z\s]+\z/
           errors.add(:name, "should only contain alphabets and spaces")
         end
    end

    def capitalize_name
       self.name = name.split.map(&:capitalize).join(" ")
    end
end
