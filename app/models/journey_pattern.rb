class JourneyPattern < ApplicationRecord
  has_many :journey_pattern_section_maps
  has_many :journey_pattern_sections, through: :journey_pattern_section_maps
  has_many :vehicle_journeys

  def self.populate_table
    refs = JourneyPatternSectionMap.pluck(:journey_pattern_ref)
    refs.uniq!
    refs.map! {|r| {
      journey_pattern_ref: r
    }}
    self.insert_all(refs)
  end
end
