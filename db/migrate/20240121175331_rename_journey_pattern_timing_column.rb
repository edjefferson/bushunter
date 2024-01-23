class RenameJourneyPatternTimingColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :journey_pattern_timing_links, :journey_pattern_id, :journey_pattern_section_id
  end
end
