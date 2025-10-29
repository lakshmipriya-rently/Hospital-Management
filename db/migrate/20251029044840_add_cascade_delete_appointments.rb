class AddCascadeDeleteAppointments < ActiveRecord::Migration[7.2]
  def change
    remove_foreign_key :appointments, :surgeries
    add_foreign_key :appointments, :surgeries, on_delete: :cascade
  end
end
