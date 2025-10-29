FactoryBot.define do
  factory :user do
     name {"Test User"}
     dob  {Faker::Date.birthday(min_age: 18, max_age: 65)}
     phone_no {"1234567867"}
     email  {Faker::Internet.unique.email}
     password {"password123"}
     password_confirmation {"password123"}

    trait :doctor do
      association :userable, factory: :doctor
      userable_type { "Doctor" }
    end

    trait :patient do
      association :userable, factory: :patient
      userable_type { "Patient" }
    end
  end

  factory :doctor do
    license_id {"doctor@2025"} 
    experience {2}
    type_of_degree {"MBBS"}
  end
  
  factory :surgery do
     name { "Appendectomy" }
     description { "Appendix removal" }
     association :doctor
  end
   
  factory :payment do
    amount_to_be_paid {100}
    association :bill
  end

  factory :patient do
    blood_group {"O+"}
    address {Faker::Address.full_address}
  end

  factory :bill do
    tot_amount {500}
    paid_amount {0}
  end


  factory :appointment do
    association :doctor
    association :patient
    status { "confirmed" }
    scheduled_at { Time.current + 1.day }
  end

  factory :available do
    start_time { 1.hour.ago }
    end_time   { 1.hour.from_now }
    available_days {['Monday']}
    association :doctor
  end
end
