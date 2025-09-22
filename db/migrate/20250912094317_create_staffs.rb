class CreateStaffs < ActiveRecord::Migration[7.2]
  def change
    create_table :staffs do |t|
      t.boolean :is_active, default: true
      t.string :shift
      t.decimal :salary, precision: 12, scale: 2, default: 0.0
      t.timestamps
    end
  end
end
