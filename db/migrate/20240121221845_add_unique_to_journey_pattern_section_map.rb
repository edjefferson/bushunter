class AddUniqueToJourneyPatternSectionMap < ActiveRecord::Migration[7.1]
  def change
    add_index :journey_pattern_section_maps, [:journey_pattern_ref, :journey_pattern_section_ref], unique: true
  end
end
