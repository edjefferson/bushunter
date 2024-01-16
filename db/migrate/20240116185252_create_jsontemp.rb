class CreateJsontemp < ActiveRecord::Migration[7.1]
  def change
    create_table :jsontemp, id: false do |t|
      t.json :doc
    end
  end
end
