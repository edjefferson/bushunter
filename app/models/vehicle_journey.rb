class VehicleJourney < ApplicationRecord
  belongs_to :journey_pattern
  has_many :journey_pattern_sections, through: :journey_pattern
  has_many :journey_pattern_section_maps, through: :journey_pattern

  has_many :journey_pattern_timing_links, through: :journey_pattern_sections

  def self.get_vehicle_journeys
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    match_query = "
    insert into vehicle_journeys (line_name, vehicle_journey_code, journey_pattern_ref, journey_pattern_id, days_of_week, departure_time, created_at, updated_at) 

    select line_name, vehicle_journey_code, journey_pattern_ref, jp.id, split_part(SUBSTRING(days_of_week::text, 2, length(days_of_week::text)),' xml',1) as days_of_week,TO_TIMESTAMP(departure_time::text, 'HH24:MI:SS'), NOW(), NOW() from
    (select
    line_name, unnest((xpath(\'//t:JourneyPatternRef/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))) as journey_pattern_ref,
    unnest((xpath(\'//t:RegularDayType/t:DaysOfWeek/*\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))) as days_of_week,
    unnest((xpath(\'//t:DepartureTime/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))) as departure_time,
    unnest((xpath(\'//t:VehicleJourneyCode/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))) as vehicle_journey_code
    from
    (select line_name, unnest(xpath(\'//t:VehicleJourney\', timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))  as vehicle_journey
    from
    (select timetable, unnest(xpath(\'//t:LineName/text()\' , timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as line_name
    from 
    (select unnest(xpath(\'//t:TransXChange\' , doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]) ) as timetable   from xmltemp) as timetables) as timetables2) as journeydata) as final_data
    join journey_patterns jp on jp.journey_pattern_ref = journey_pattern_ref
    on conflict (vehicle_journey_code) do nothing"

    result = rc.exec(match_query)
    puts result.inspect
  end


  def self.get_timetable(stop,line_name)
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    

    days_of_week = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ]

    days_of_week_map = []
    days_of_week.each_with_index { |d,i|
      output = [d, "MondayToSunday"]
      output << "MondayToFriday" if i > 0 && i < 6
      output << "MondayToSaturday" if i > 0 && i < 7
      output << "Weekend" if i == 0 || i == 6
      days_of_week_map << output
    }

    timetable = days_of_week_map.map do |dow|
      journeys = []
      puts dow
      VehicleJourney.includes(:journey_pattern_section_maps).where(line_name: line_name, days_of_week: dow).where.not(journey_pattern_id: nil).each do |v|
        
        query = "select jpm.id, from_stop, to_stop, (SUM(COALESCE(run_time,\'PT0S\'::interval) + COALESCE(wait_time,\'PT0S\'::interval)) OVER (PARTITION BY (jpm.journey_pattern_section_id) ORDER BY jpsm.id, jpm.id ROWS UNBOUNDED PRECEDING)) AS total_time_since_start 
        from journey_patterns jp
        join journey_pattern_section_maps jpsm on jpsm.journey_pattern_id = jp.id
        join journey_pattern_timing_links jpm on jpsm.journey_pattern_section_id = jpm.journey_pattern_section_id
        where jp.id = #{v.journey_pattern_id}"

        result = rc.exec(query)
        #puts result[0]
        if result.select{|r| r["from_stop"] == stop}[0]
          journeys << [v.id,v.vehicle_journey_code, v.departure_time, result.select{|r| r["from_stop"] == "490014816E"}[0]["total_time_since_start"]]
        end
      
      end
      journeys.map {|x|  (x[2] + ActiveSupport::Duration.parse(x[3])).strftime("%H:%M")}.sort
    end

    timetable.each_with_index {|t,i| 
    puts days_of_week_map[i]
    puts [i,t].inspect
  }  
    
    
  end
        
end
