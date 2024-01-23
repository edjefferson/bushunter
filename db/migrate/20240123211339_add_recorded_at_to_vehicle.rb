class AddRecordedAtToVehicle < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :recorded_at, :timestamp
  end
end
