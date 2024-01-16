class AddStopIdIndexToArrivalUpdate < ActiveRecord::Migration[7.1]
  def change
    add_index :arrival_updates, :stop_id, unique: false
  end
end
