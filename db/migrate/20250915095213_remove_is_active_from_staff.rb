class RemoveIsActiveFromStaff < ActiveRecord::Migration[7.2]
  def change
    remove_column :staffs, :is_active, :boolean
  end
end
