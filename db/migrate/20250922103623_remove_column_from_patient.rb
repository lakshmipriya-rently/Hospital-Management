class RemoveColumnFromPatient < ActiveRecord::Migration[7.2]
  def change
    remove_column :patients,:disease,:string 
  end
end
