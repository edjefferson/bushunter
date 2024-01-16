class AddStopLetterToStopPoint < ActiveRecord::Migration[7.1]
  def change
    add_column :stop_points, :stop_letter, :text
  end
end
