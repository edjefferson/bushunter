class AddType < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL

      CREATE TYPE update_type as ("naptanId" text, "stationName" text, "lineName" text, "platformName" text, "direction" text, "destinationName" text, "vehicleId" text, "expectedArrival" timestamp, timestamp timestamp);

      
    SQL
    
  end

  def down
    execute "DROP TYPE update_type"
  end
end

  
