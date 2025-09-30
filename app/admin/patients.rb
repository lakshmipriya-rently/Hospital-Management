ActiveAdmin.register Patient do              
  index do
    selectable_column
    id_column
    column "Email" do |patient|
       patient.user.email
    end
    column :blood_group
    column :organ_donor
    column :address
    actions
  end
  
end
