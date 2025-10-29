class AddNullifyToAppointments < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :appointments, :patients
    add_foreign_key :appointments, :patients, on_delete: :nullify
  end
end
