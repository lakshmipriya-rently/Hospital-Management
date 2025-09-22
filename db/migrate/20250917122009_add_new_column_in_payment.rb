class AddNewColumnInPayment < ActiveRecord::Migration[7.2]
  def change
    add_column :payments, :amount_to_be_paid, :integer
  end
end
