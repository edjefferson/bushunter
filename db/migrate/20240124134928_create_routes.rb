class CreateRoutes < ActiveRecord::Migration[7.1]
  def change
    create_table :routes do |t|
      t.text :line_name
      t.text :direction
      t.text :linestrings

      t.timestamps
    end
  end
end
