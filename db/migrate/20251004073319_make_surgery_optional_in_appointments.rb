class MakeSurgeryOptionalInAppointments < ActiveRecord::Migration[7.2]
  def change
        change_column_null :appointments, :surgery_id, true
  end
end
