class AddUniqueKeyToStopPoint < ActiveRecord::Migration[7.1]
  def change
    add_index :stop_points, :stop_id, unique: true
  end
end
