class CreateAppointments < ActiveRecord::Migration[7.2]
  def change
    create_table :appointments do |t|
      t.references :doctor, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.date :appointment_date
      t.time :appointment_time
      t.string :patient_name
      t.string :email
      t.integer :status, default: false, null: false
      t.timestamps
    end
  end
end
