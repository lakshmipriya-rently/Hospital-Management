class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :appointment,null: false,foreign_key: true
      t.references :bill,null: false,foreign_key: true
      t.references :patient,null: false,foreign_key: true
      t.string :payment_method
      t.integer :status,default: 0,null:false
      t.timestamps
    end
  end
end
 