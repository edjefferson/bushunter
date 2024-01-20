class Journey < ApplicationRecord
  has_many :journey_pattern_timing_links, primary_key: 'journey_pattern_id', foreign_key: 'journey_pattern_id'
end
