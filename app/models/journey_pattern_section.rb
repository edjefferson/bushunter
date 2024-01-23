class JourneyPatternSection < ApplicationRecord
  has_many :journey_pattern_timing_links
  has_many :journey_pattern_section_maps

  


  def self.populate_table
    refs = JourneyPatternSectionMap.pluck(:journey_pattern_section_ref)
    refs.uniq!
    refs.map! {|r| {
      journey_pattern_section_ref: r
    }}
    self.insert_all(refs)
  end
end


