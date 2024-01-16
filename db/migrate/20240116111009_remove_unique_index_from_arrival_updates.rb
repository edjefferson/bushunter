class RemoveUniqueIndexFromArrivalUpdates < ActiveRecord::Migration[7.1]
  def change
    remove_index :arrival_updates, [:timestamp, :vehicle_id, :stop_id, :line_name], unique: true
  end
end
