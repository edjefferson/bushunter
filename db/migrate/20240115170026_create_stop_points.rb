class CreateStopPoints < ActiveRecord::Migration[7.1]
  def change
    create_table :stop_points do |t|
      t.text :stop_id
      t.text :name
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end
