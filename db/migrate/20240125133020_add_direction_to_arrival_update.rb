class AddDirectionToArrivalUpdate < ActiveRecord::Migration[7.1]
  def change
    add_column :arrival_updates, :direction, :text
  end
end
