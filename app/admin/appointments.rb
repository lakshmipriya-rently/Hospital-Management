ActiveAdmin.register Appointment do
  
   scope :confirmed
   scope :pending
   
  index do
    selectable_column
    id_column
    column "Email" do |appointment|
       appointment.patient.user.email
    end
    column :disease
    column :scheduled_at
    column :status
    actions
  end
  
end
