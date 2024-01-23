class AddArrivalTimeToJourneyPatternTimeLink < ActiveRecord::Migration[7.1]
  def change
    add_column :journey_pattern_timing_links, :total_time_since_start, :interval
  end
end
