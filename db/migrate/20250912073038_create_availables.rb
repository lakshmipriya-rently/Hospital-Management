class CreateAvailables < ActiveRecord::Migration[7.0]
  def change
    create_table :availables do |t|
      t.references :doctor, null: false, foreign_key: true
      t.jsonb :available_days, null: false, default: []
      t.time :start_time
      t.time :end_time
      t.boolean :is_active, default: true
      t.timestamps
    end
  end
end
