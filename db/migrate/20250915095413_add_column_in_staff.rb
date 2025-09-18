class AddColumnInStaff < ActiveRecord::Migration[7.2]
  def change
    add_column :staffs,:is_permanant,:boolean
    add_column :staffs,:qualification,:string
  end
end
