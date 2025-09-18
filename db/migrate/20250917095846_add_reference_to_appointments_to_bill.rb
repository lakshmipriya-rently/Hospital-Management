class AddReferenceToAppointmentsToBill < ActiveRecord::Migration[7.2]
  def change
    add_reference :bills,:appointment,foreign_key: true
  end
end
