class AddNullifyToBillsAndPayments < ActiveRecord::Migration[7.2]
  def change
     remove_foreign_key :bills, :appointments
     add_foreign_key :bills, :appointments, on_delete: :nullify
     remove_foreign_key :payments, :bills
     add_foreign_key :payments, :bills, on_delete: :nullify  
  end
end
