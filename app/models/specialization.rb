class Specialization < ApplicationRecord
    include Ransackable
    has_and_belongs_to_many :doctors
end
