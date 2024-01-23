class AddRefFieldToJourneyPatternTimingLink < ActiveRecord::Migration[7.1]
  def change
    add_column :journey_pattern_timing_links, :journey_pattern_timing_link_ref, :text
    add_index :journey_pattern_timing_links, :journey_pattern_timing_link_ref, unique: true
  end
end
