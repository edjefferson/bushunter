class CreateJourneys < ActiveRecord::Migration[7.1]
  def change
    create_table :journeys do |t|
      t.text :line_id
      t.text :journey_pattern_id
      t.time :departure_time
      t.text :days_of_week

      t.timestamps
    end
  end
end
