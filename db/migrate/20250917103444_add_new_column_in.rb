class AddNewColumnIn < ActiveRecord::Migration[7.2]
  def change
    add_column :bills, :is_assigned, :boolean
  end
end
