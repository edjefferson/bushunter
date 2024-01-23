class ChangeJourneyPatternSectionColumns < ActiveRecord::Migration[7.1]
  def change
    remove_column(:journey_pattern_sections, :journey_pattern_id, :text)
  end
end
