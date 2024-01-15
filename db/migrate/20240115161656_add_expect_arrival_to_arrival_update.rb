class AddExpectArrivalToArrivalUpdate < ActiveRecord::Migration[7.1]
  def change
    add_column :arrival_updates, :expected_arrival, :timestamp
  end
end
