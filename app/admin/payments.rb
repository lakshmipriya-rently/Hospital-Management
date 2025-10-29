ActiveAdmin.register Payment do

  scope :un_paid
  scope :paid
 
  filter :payment_method
  filter :status

  
  index do
    selectable_column
    id_column
    column "Email" do |payment|
       payment.bill.appointment.patient.user.email
    end
    column :amount_to_be_paid
    column :payment_method
    column :status
    actions
  end
  
  
end
