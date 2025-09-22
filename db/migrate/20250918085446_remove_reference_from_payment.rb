class RemoveReferenceFromPayment < ActiveRecord::Migration[7.2]
  def change
    remove_reference :payments, :patient, foreign_key: true
    remove_reference :payments, :appointment, foreign_key: true
  end
end
