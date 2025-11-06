ActiveAdmin.register Doctor do
  scope :all
  scope :inactive_now
  scope :active_now

  filter :experience
  filter :type_of_degree
  filter :salary
  filter :created_at
  filter :start_time
  filter :specializations, as: :select, collection: Proc.new { Specialization.all.pluck(:specialization, :id) }

  index do
  selectable_column
  id_column
  column :license_id
  column :experience
  column :type_of_degree
  column :salary
  column "Specialization" do |doctor|
      doctor.specializations.pluck(:specialization).join(", ")
  end
  column "Active Status" do |doctor|
  if doctor.active_now?
    status_tag "Active", class: "status-ok"
  else
    status_tag "Inactive", class: "status-error"
  end
end
  column "Email" do |doctor|
    doctor.user.email
  end
  column :created_at
  actions
end

action_item :view, only: :show do
  link_to "View on site", doctor_path(resource.user)
end

form do |f|
  f.semantic_errors
  f.inputs
  f.inputs do
    f.has_many :user, heading: "User Details", allow_destroy: true do |a|
      a.input :name
      a.input :email
      a.input :password
      a.input :password_confirmation
    end
  end
  f.actions
end
end
