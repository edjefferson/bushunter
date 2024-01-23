class CreateJourneyPatternSectionMaps < ActiveRecord::Migration[7.1]
  def change
    create_table :journey_pattern_section_maps do |t|
      t.text :journey_pattern_ref
      t.references :journey_pattern, foreign_key: true
      t.text :journey_pattern_section_ref
      t.references :journey_pattern_section, foreign_key: true

      t.timestamps
    end
  end
end
