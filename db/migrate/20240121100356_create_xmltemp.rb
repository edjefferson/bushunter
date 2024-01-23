class CreateXmltemp < ActiveRecord::Migration[7.1]
  def change
    create_table :xmltemp, id: false do |t|
      t.xml :doc
    end
  end
end
