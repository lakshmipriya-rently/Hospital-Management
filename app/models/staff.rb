class Staff < ApplicationRecord
    has_many :users, as: :userable
    validates :salary, :qualification, :is_permanant, :shift, presence: true
end
