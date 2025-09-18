class CreateBills < ActiveRecord::Migration[7.2]
  def change
    create_table :bills do |t|
      t.references :doctor,null: false,foreign_key: true
      t.references :patient,null: false,foreign_key: true
      t.date :bill_date
      t.decimal :tot_amount, precision: 12,scale: 2,default:0.0
      t.decimal :paid_amount, precision: 12,scale: 2,default:0.0 
      t.timestamps
    end
  end
end
