class CreateVehicleJourneyDays < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicle_journey_days do |t|
      t.references :vehicle_journey, foreign_key: true
      t.text :vehicle_journey_code
      t.text :day_of_week
      t.timestamps
    end
  end
end
