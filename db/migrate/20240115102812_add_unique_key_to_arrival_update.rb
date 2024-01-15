class AddUniqueKeyToArrivalUpdate < ActiveRecord::Migration[7.1]
  def change
    add_index :arrival_updates, [:timestamp, :vehicle_id, :stop_id, :line_name], unique: true
  end
end
