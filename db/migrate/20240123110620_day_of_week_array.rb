class DayOfWeekArray < ActiveRecord::Migration[7.1]
  def change
    remove_column :vehicle_journeys, :days_of_week, :text
    add_column :vehicle_journeys, :days_of_week, :text, array: true
  end
end
