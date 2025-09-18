class CreatePatients < ActiveRecord::Migration[7.2]
  def change
    create_table :patients do |t|
      t.string :blood_group
      t.string :disease
      t.boolean :organ_donor, default: false
      t.string :address
      t.timestamps
    end
  end
end
