class MakeJourneyPatternSectionIdinteger < ActiveRecord::Migration[7.1]
  def change
    remove_column(:journey_pattern_timing_links, :journey_pattern_section_id, :text)

    add_reference(:journey_pattern_timing_links, :journey_pattern_section)
  end
end
