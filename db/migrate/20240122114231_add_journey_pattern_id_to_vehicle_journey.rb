class AddJourneyPatternIdToVehicleJourney < ActiveRecord::Migration[7.1]
  def change
    add_reference :vehicle_journeys, :journey_pattern, foreign_key: true
  end
end
