class CreateVehicleJourneys < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicle_journeys do |t|
      t.text :line_name
      t.text :journey_pattern_ref
      t.text :days_of_week
      t.time :departure_time

      t.timestamps
    end
  end
end
