require 'csv'
require 'time'
require 'open-uri'

class ArrivalUpdate < ApplicationRecord
  

  def self.runquery
    puts "dot"
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    #
    
    puts "eggy"


    match_query = """select (xpath(\'//t:JourneyPatternTimingLink/t:From/t:StopPointRef/text()\' , jps, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as from,
    (xpath(\'//t:JourneyPatternTimingLink/t:To/t:StopPointRef/text()\' , jps, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as to,
    (xpath(\'//t:JourneyPatternTimingLink/t:RunTime/text()\' , jps, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as run_time,
    (xpath(\'//t:JourneyPatternTimingLink/t:WaitTime/text()\' , jps, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as wait_time,
    id as jps_id,
    line_name as line_name
    
    from (select line_name, unnest(xpath(\'//t:JourneyPatternSection\', tt, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))  as jps,
    unnest(xpath(\'//t:JourneyPatternSection/@id\' , tt, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as id
    from (select timetable as tt, unnest(xpath(\'//t:LineName/text()\' , timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as line_name from (select unnest(xpath(\'//t:TransXChange\' , doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]) ) as timetable   from xmltemp ) as timetables) as timetables2) as jpslist limit 10"""
    
    match_query = "
  insert into journey_pattern_sections (journey_pattern_section_ref,journey_pattern_id, created_at,updated_at)
    select unnest(xpath(\'//t:JourneyPatternSectionRefs/text()\', journey_patterns, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey_pattern_section_ref, 
    
    unnest(xpath(\'//@id\', journey_patterns, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey_pattern_id, NOW(), NOW()
    from
    (select
    unnest(xpath(\'//t:JourneyPattern\', service, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey_patterns from
    (select line_name, unnest(xpath(\'//t:Service\', timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))  as service
    from
    (select timetable, unnest(xpath(\'//t:LineName/text()\' , timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as line_name
    from 
    (select unnest(xpath(\'//t:TransXChange\' , doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]) ) as timetable   from xmltemp) as timetables) as timetables2) as servicedata) as journeypatternsdata"
    result = rc.exec(match_query)
    #puts result.inspect
    
    result.each do |r|
      puts r
      
    end
  end

  def self.loadXmlToDb(z,xmltemp)
    puts "opening"
    #puts #
    doc = Nokogiri::XML(z)
    start_date = doc.css('TransXChange/Services/Service/OperatingPeriod/StartDate').inner_text
    end_date = doc.css('TransXChange/Services/Service/OperatingPeriod/EndDate').inner_text
    if Date.today >= Date.parse(start_date) && Date.today <= Date.parse(end_date)
      xmltemp << {doc: z}
      if xmltemp.count > 10
        puts "db dumping"
        Xmltemp.insert_all(xmltemp)
        
        xmltemp = []
      end
      
    end
    xmltemp
  end
  def self.process_zip(zip_data,xmltemp)
      Zip::File.open_buffer(zip_data) do |zip|
        zip.each do |entry|
          
          puts entry.name
          
          xmltemp = loadXmlToDb(entry.get_input_stream.read,xmltemp)
        end
      end
    
  end
  def self.load_timetable

    #url = "http://localhost:3000/journey-planner-timetables.zip"
    url = "https://tfl.gov.uk/tfl/syndication/feeds/journey-planner-timetables.zip"
    hash = {}
    zip_data = []
    unzip_data = {}
    xmltemp = []
    Xmltemp.delete_all

    Zip::File.open_buffer(URI.open(url)) do |zip|
      zip.each do |entry|
          # All required operations on `entry` go here.
        puts entry.name
        process_zip(entry.get_input_stream.read,xmltemp)
      end
    end
    puts "egg"
    Xmltemp.insert_all(xmltemp)

    

    #filebody = URI.open(url)
    #filebody = File.open("test.xml")
    #logger.info "#{Time.now} data pulled down"
    puts "#{Time.now} data pulled down"
    
    logger.info "#{Time.now} data in db #{result.cmd_status}"
    puts "#{Time.now} data in db #{result.cmd_status}" 
  end

  def self.check_bus_timetable
    jptl = 0
    jc = 0
    Journey.delete_all
    JourneyPatternTimingLink.delete_all
    url = "http://localhost:3000/journey-planner-timetables.zip"
    #url = "https://tfl.gov.uk/tfl/syndication/feeds/journey-planner-timetables.zip"
    hash = {}
    zip_data = []
    unzip_data = {}
    Zip::File.open_buffer(URI.open(url)) do |zip|
      zip.each do |entry|
          # All required operations on `entry` go here.
        puts entry.name
       
        zip_data << entry.get_input_stream.read
      end
    end
    puts "egg"
    zip_data.each do |z|
      Zip::File.open_buffer(z) do |zip|
        zip.each do |entry|
          
            puts entry.name
          
            unzip_data[entry.name] = entry.get_input_stream.read
            break
        end
      end
    end
    unzip_data.sort_by{|k,v| k}.to_h.each do |k,z|
      puts k
      xml = z
      doc = Nokogiri::XML(xml)
      
      services = {}

      doc.css('TransXChange/Services/Service/Lines/Line').each do |line|
        services[line.attr("id").to_s] = line.css("LineName").inner_text
      end

      start_date = doc.css('TransXChange/Services/Service/OperatingPeriod/StartDate').inner_text
      end_date = doc.css('TransXChange/Services/Service/OperatingPeriod/EndDate').inner_text
      if Time.now >= Time.parse(start_date) && Time.now <= Time.parse(end_date)

        journeys = doc.css('TransXChange/VehicleJourneys/VehicleJourney').map do |j|
          days_of_week = j.css('OperatingProfile/RegularDayType/DaysOfWeek').inner_html.strip
          days_of_week = days_of_week ? days_of_week.split(">")[0].to_s[1..-1]: nil
      
          
          
          service_id = j.css("JourneyPatternRef").inner_text.split("-")[0..4].join("-")
          service_id = service_id.split("_")[1..-1].join("_")
     
          if days_of_week == "Sunday"
            {
              line_id: services[service_id],
              journey_pattern_id: j.css("JourneyPatternRef").inner_text.split("_")[1..-1].join("_"),
              departure_time: j.css("DepartureTime").inner_text,
              days_of_week: days_of_week
            }
          else
            nil
          end
        end
        puts jc
        puts journeys.count
        journeys.compact!
        puts journeys.count
        jids = journeys.map {|j| j[:journey_pattern_id]}
        #Journey.insert_all(journeys)
        jc += journeys.count

        journey_pattern_timing_links = doc.css('TransXChange/JourneyPatternSections/JourneyPatternSection').map do |j|
          total_run_time = 0

          j.css('JourneyPatternTimingLink').map do |link|

            service_id = j.attr("id").split("-")[0..4].join("-")
            service_id = service_id.split("_")[1..-1].join("_")
            run_time = ISO8601::Duration.new(link.css("RunTime").inner_text).to_seconds.to_i
            old_total_run_time = total_run_time.dup
            total_run_time += run_time
            jpid = link.attr('id').split("-")[0..-2].join("-").split("_")[1..-1].join("_")
            if jids.include?(jpid)
              {
                line_id: services[service_id],
                journey_pattern_id: jpid,
                from: link.css("From/StopPointRef").inner_text,
                to: link.css("To/StopPointRef").inner_text,
                run_time: run_time,
                run_time_to_stop: old_total_run_time
              }
            else
              nil
            end

            
          end
          
        end
        journey_pattern_timing_links.compact!
        jptl += journey_pattern_timing_links.flatten.length
        #JourneyPatternTimingLink.insert_all(journey_pattern_timing_links.flatten)
       
      end

      puts [jptl,jc].inspect

    end
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
          Vehicle.pull_data
          last_time = Time.now
          last_full_check = Time.now
          self.pull_json(-1)
        elsif (Time.now - last_time) > 10
          Vehicle.pull_data
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

