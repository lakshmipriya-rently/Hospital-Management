class AddSurgeryToAppointments < ActiveRecord::Migration[7.2]
  def change
    add_reference :appointments, :surgery, null: true, foreign_key: true
  end
end
