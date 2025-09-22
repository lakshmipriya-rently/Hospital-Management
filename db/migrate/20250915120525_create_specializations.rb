class CreateSpecializations < ActiveRecord::Migration[7.2]
  def change
    create_table :specializations do |t|
      t.string :specialization, null: false
      t.timestamps
    end
  end
end
