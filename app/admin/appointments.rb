ActiveAdmin.register Appointment do
  
   scope :confirmed
   scope :pending

   filter :scheduled_at 
   filter :status
   filter :disease    

  index do
    selectable_column
    id_column
    column "Email" do |appointment|
       appointment.patient.user.email
    end
    column :disease
    column "Date" do |appointment|
       appointment.scheduled_at.strftime("%d-%m-%Y")
    end
    column "Time" do |appointment|
       appointment.scheduled_at.strftime("%I:%M %p")
    end
    column :status
    actions
  end
  
end
