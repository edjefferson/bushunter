class AddIndexArrivalUpdate < ActiveRecord::Migration[7.1]
  def change
    add_index :arrival_updates, [:vehicle_id, :stop_id], unique: true
  end
end
