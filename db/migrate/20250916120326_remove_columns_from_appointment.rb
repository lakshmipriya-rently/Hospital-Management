class RemoveColumnsFromAppointment < ActiveRecord::Migration[7.2]
  def change
    remove_column :appointments,:patient_name,:string
    remove_column :appointments,:email,:email
  end
end
