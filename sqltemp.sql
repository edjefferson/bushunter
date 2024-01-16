

  create table arrivalt (stop_id text, vehicle_id text, expected_arrival timestamp, timestamp timestamp)

  ALTER TABLE arrival_updates ADD CONSTRAINT constraintarr UNIQUE (stop_id, stop_name, vehicle_id, line_name, platform_name, destination_name);

  def self.test_json_import
    ActiveRecord::Base.connection.execute(`
    create unlogged table customer_import (doc json);
    \\copy customer_import from 'test.json' ....
    `)

    select * from json_populate_recordset(null::update_type,(select doc ))

 SELECT id, (json_populate_recordset(null::update_type, doc)).* FROM jsontemp;

CREATE TYPE update_type as ("naptanId" text, "stationName" text, "lineName" text, "platformName" text, "destinationName" text, "vehicleId" text, "expectedArrival" timestamp, timestamp timestamp);

    insert into arrival_updates (stop_id, stop_name, line_name, platform_name, destination_name, vehicle_id, expected_arrival, timestamp, created_at, updated_at)
select distinct q."naptanId", q."stationName", q."lineName", q."platformName", q."destinationName", q."vehicleId", max(q."expectedArrival"), max(q.timestamp), now() as created_at, now() as updated_at from
(select p."naptanId", p."stationName", p."lineName", p."platformName", p."destinationName", p."vehicleId",p."expectedArrival",cast(p.timestamp AS TIMESTAMP)
from jsontemp l
  cross join lateral json_populate_recordset(null::update_type, doc) as p) as q
 group by q."naptanId", q."stationName", q."lineName", q."platformName", q."destinationName", q."vehicleId"
on conflict (stop_id, stop_name, line_name, platform_name, destination_name, vehicle_id) do update 
  set expected_arrival = excluded.expected_arrival, 
  timestamp = excluded.timestamp,
  updated_at = excluded.updated_at;

    select p.*
from customer_import l
  cross join lateral json_populate_recordset(null::arrival_updates, doc) as p

  end


  select json_populate_recordset(null::update_type, doc) from jsontemps l
  cross join lateral json_populate_recordset(null::update_type, doc) as p