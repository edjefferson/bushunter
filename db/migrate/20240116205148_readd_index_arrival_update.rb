class ReaddIndexArrivalUpdate < ActiveRecord::Migration[7.1]
  def change
      add_index :arrival_updates, [:vehicle_id, :stop_id, :stop_name, :line_name, :platform_name, :destination_name], unique: true
  end
end
