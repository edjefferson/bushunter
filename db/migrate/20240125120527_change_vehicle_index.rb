class ChangeVehicleIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :vehicles, :vehicle_ref, unique: true
    add_index :vehicles, [:vehicle_ref, :recorded_at], unique: true
  end
end
