require 'csv'
require 'time'
class ArrivalUpdate < ApplicationRecord
  def self.pull_json(pull_count)
    app_key = ENV['TFL_APP_KEY']
    url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?count=#{pull_count}&app_key=#{app_key}"
    filebody = URI.open(url)
    logger.info "#{Time.now} data pulled down"
    puts "#{Time.now} data pulled down"
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    rc.exec("truncate table jsontemp")
    rc.exec("COPY jsontemp FROM STDIN")

    while !filebody.eof?
      rc.put_copy_data(filebody.readline)
    end

    rc.put_copy_end

    while res = rc.get_result
      if e_message = res.error_message
        puts e_message
      end
    end

    match_query = 'insert into arrival_updates (stop_id, stop_name, line_name, platform_name, destination_name, vehicle_id, expected_arrival, timestamp, created_at, updated_at)
      select distinct q."naptanId", q."stationName", q."lineName", q."platformName", q."destinationName", q."vehicleId", max(q."expectedArrival"), max(q.timestamp) as mtimestamp , now() as created_at, now() as updated_at from
      (select p."naptanId", p."stationName", p."lineName", p."platformName", p."destinationName", p."vehicleId",p."expectedArrival",cast(p.timestamp AS TIMESTAMP)
      from jsontemp l
      cross join lateral json_populate_recordset(null::update_type, doc) as p) as q
      group by q."naptanId", q."stationName", q."lineName", q."platformName", q."destinationName", q."vehicleId"
      on conflict (stop_id, stop_name, line_name, platform_name, destination_name, vehicle_id) do update 
      set expected_arrival = excluded.expected_arrival, 
      timestamp = excluded.timestamp,
      updated_at = excluded.updated_at
      where arrival_updates.timestamp < excluded.timestamp;'
    result = rc.exec(match_query)
    logger.info "#{Time.now} data in db #{result.cmd_status}"
    puts "#{Time.now} data in db #{result.cmd_status}" 

  end

  def self.update_request(pull_count,last_updates)
    begin
      app_key = ENV['TFL_APP_KEY']
      url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?count=#{pull_count}&app_key=#{app_key}"
      self.pull_json(pull_count)
      


      puts "#{updates.count} records after dedupe"
      
      updates.each_slice(10000) { |slice|
        self.upsert_all(slice, unique_by: [:vehicle_id,:stop_id])
      }
     

      logger.info "#{Time.now} import complete"
      puts "#{Time.now} import complete"
      
      return updates + last_updates
    rescue => e
      puts e
      return last_updates
    end
  end

  def self.fetch_updates
    last_time = Time.now - 90
    while true
      
      if (Time.now() - last_time) > 60
        ArrivalUpdate.where("created_at < '#{40.minutes.ago}'").delete_all
        self.pull_json(-1)
        last_time = Time.now
      else
        self.pull_json(5)
      end
      
    end
  end
end
