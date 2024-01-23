class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.text :line_name
      t.text :vehicle_ref
      t.float :latitude
      t.float :longitude
      t.float :bearing

      t.timestamps
    end

    add_index :vehicles, :vehicle_ref, unique: true

  end
end
