class RemoveReferenceFromBill < ActiveRecord::Migration[7.2]
  def change
    remove_reference :bills, :doctor, foreign_key: true
    remove_reference :bills, :patient, foreign_key: true
  end
end
