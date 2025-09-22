class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.references :userable,polymorphic: true,null:true
      t.string :name
      t.date :dob
      t.integer :age
      t.string :gender
      t.string :phone_no
      t.timestamps
    end
  end
end
