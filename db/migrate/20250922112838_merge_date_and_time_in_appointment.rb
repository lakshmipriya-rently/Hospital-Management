class MergeDateAndTimeInAppointment < ActiveRecord::Migration[7.2]
  def change
    add_column :appointments, :scheduled_at, :datetime

    remove_column :appointments, :appointment_date, :date
    remove_column :appointments, :appointment_time, :time
  end
end
