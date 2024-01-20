require 'csv'
require 'time'
require 'open-uri'

class ArrivalUpdate < ApplicationRecord

  def self.check_bus_timetable
    Journey.delete_all
    JourneyPatternTimingLink.delete_all
    url = "http://localhost:3000/journey-planner-timetables.zip"
    #url = "https://tfl.gov.uk/tfl/syndication/feeds/journey-planner-timetables.zip"
    hash = {}
    zip_stream = Zip::InputStream.new(URI.open(url))
    while entry = zip_stream.get_next_entry
        # All required operations on `entry` go here.
      puts entry.name
      Zip::InputStream.open(StringIO.new(entry.get_input_stream.read)) do |io|
        while subentry = io.get_next_entry
          xml = subentry.get_input_stream.read
          hash = Hash.from_xml(xml)
          #puts hash.keys
          services = {}
          hash['TransXChange']['Services']['Service']['Lines'].each do |k,v|

            services[v["id"]] = v["LineName"]
          end
          journey_pattern_timing_links = hash['TransXChange']['JourneyPatternSections']['JourneyPatternSection'].map do |j|
            total_run_time = 0

            j['JourneyPatternTimingLink'].map do |link|
  
              service_id = j["id"].split("-")[0..4].join("-")
              service_id = service_id.split("_")[1..-1].join("_")
              run_time = ISO8601::Duration.new(link["RunTime"]).to_seconds.to_i
              old_total_run_time = total_run_time.dup
              total_run_time += run_time

              {
                line_id: services[service_id],
                journey_pattern_id: link["id"].split("-")[0..-2].join("-").split("_")[1..-1].join("_"),
                from: link["From"]["StopPointRef"],
                to: link["To"]["StopPointRef"],
                run_time: run_time,
                run_time_to_stop: old_total_run_time
              }
            end
          end
          JourneyPatternTimingLink.insert_all(journey_pattern_timing_links.flatten)
          
          journeys = hash['TransXChange']['VehicleJourneys']['VehicleJourney'].map do |j|

            days_of_week = j["OperatingProfile"]["RegularDayType"]["DaysOfWeek"].keys[0]
            service_id = j["JourneyPatternRef"].split("-")[0..4].join("-")
            service_id = service_id.split("_")[1..-1].join("_")

              {
                line_id: services[service_id],

                journey_pattern_id: j["JourneyPatternRef"].split("_")[1..-1].join("_"),
                departure_time: j["DepartureTime"],
                days_of_week: days_of_week
              }
          end
          Journey.insert_all(journeys)

          
        end
      end

      break
    end
    return hash
  end

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
      select distinct q."naptanId", q."stationName", q."lineName", q."platformName", q."destinationName",q."vehicleId", max(q."expectedArrival"), max(q.timestamp) as mtimestamp , now() as created_at, now() as updated_at from
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
    last_full_check = Time.now - 90
    last_delete = Time.now - 305
    continue = true
    while continue
      begin
        if (Time.now - last_delete) > 300
          ArrivalUpdate.where("created_at < '#{40.minutes.ago}'").delete_all
          last_delete = Time.now
        end

        if (Time.now - last_full_check) > 60
          last_time = Time.now
          last_full_check = Time.now
          self.pull_json(-1)
        elsif (Time.now - last_time) > 10
          last_time = Time.now
          self.pull_json(5)
        end
      rescue => e
        contine = false
        logger.info "#{e}"
        puts "#{e}"
      end

      
    end
  end
end

