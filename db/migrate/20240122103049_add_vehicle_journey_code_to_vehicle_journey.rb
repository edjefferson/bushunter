class AddVehicleJourneyCodeToVehicleJourney < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicle_journeys, :vehicle_journey_code, :text
    add_index :vehicle_journeys, :vehicle_journey_code, unique: true

  end
end
