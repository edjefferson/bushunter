class JourneyPatternTimingLink < ApplicationRecord
  belongs_to :journey, primary_key: 'journey_pattern_id', foreign_key: 'journey_pattern_id'
end
