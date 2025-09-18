class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name 
      t.bigint :userable_id
      t.string :userable_type
      t.string :email
      t.string :phone_no
      t.string :gender
      t.string :age
      t.timestamps      
    end
  end
end
