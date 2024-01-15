class CreateArrivalUpdates < ActiveRecord::Migration[7.1]
  def change
    create_table :arrival_updates do |t|
      t.text :stop_id
      t.text :stop_name
      t.text :vehicle_id
      t.integer :time_to_station
      t.text :line_name
      t.timestamp :timestamp

      t.timestamps
    end
  end
end
