class CreateJourneyPatternSections < ActiveRecord::Migration[7.1]
  def change
    create_table :journey_pattern_sections do |t|
      t.text :journey_pattern_section_ref
      t.text :journey_pattern_id

      t.timestamps
    end
  end
end
