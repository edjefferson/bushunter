class CreateJourneyPatternTimingLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :journey_pattern_timing_links do |t|
      t.text :line_id
      t.text :journey_pattern_id
      t.text :from
      t.text :to
      t.integer :run_time
      t.integer :run_time_to_stop
      t.timestamps
    end
  end
end
