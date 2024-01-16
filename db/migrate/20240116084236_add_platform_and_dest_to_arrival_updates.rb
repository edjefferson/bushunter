class AddPlatformAndDestToArrivalUpdates < ActiveRecord::Migration[7.1]
  def change
    add_column :arrival_updates, :platform_name, :text
    add_column :arrival_updates, :destination_name, :text
  end
end
