class Payment < ApplicationRecord
    enum status: {
     pending: 0,
     paid: 1,
     un_paid: 2
    }

    belongs_to :bill
end
