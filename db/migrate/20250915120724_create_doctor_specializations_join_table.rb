class CreateDoctorSpecializationsJoinTable < ActiveRecord::Migration[7.2]
  def change
    create_join_table :doctors,:specializations do |j|
      j.index :doctor_id
      j.index :specialization_id 
    end
  end
end
