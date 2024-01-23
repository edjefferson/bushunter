class CreateJourneyPatterns < ActiveRecord::Migration[7.1]
  def change
    create_table :journey_patterns do |t|
      t.text :journey_pattern_ref

      t.timestamps
    end
  end
end
