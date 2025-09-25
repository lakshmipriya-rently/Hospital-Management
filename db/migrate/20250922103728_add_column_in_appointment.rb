class AddColumnInAppointment < ActiveRecord::Migration[7.2]
  def change
    add_column :appointments,:disease,:string
  end
end
