ActiveAdmin.register Patient do     
  
  filter :blood_group
  filter :organ_donor

  index do
    selectable_column
    id_column
    column "Name" do |patient|
       patient.user&.name || "No user linked"
    end
    column "Email" do |patient|
       patient.user&.email || "No email"
    end
    column :blood_group
    column :organ_donor
    column :address
    actions
  end

  
end
