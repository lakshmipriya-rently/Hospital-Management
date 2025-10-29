class CreateSurgeries < ActiveRecord::Migration[7.2]
  def change
    create_table :surgeries do |t|
      t.string :name
      t.text :description
      t.references :doctor, null: false, foreign_key: true

      t.timestamps
    end
  end
end
