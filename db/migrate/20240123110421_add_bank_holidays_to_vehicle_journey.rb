class AddBankHolidaysToVehicleJourney < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicle_journeys, :bh_days_operating, :text, array: true
    add_column :vehicle_journeys, :bh_days_not_operating, :text, array: true
    add_column :vehicle_journeys, :special_days_starts, :text, array: true
    add_column :vehicle_journeys, :special_days_ends, :text, array: true
  end
end
