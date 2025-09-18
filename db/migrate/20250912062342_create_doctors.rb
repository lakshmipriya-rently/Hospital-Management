class CreateDoctors < ActiveRecord::Migration[7.2]
  def change
    create_table :doctors do |t|
      t.string :license_id
      t.integer :experience
      t.string :type_of_degree
      t.decimal :salary, precision: 12,scale: 2,default:0.0
      t.timestamps
    end
  end
end
