class VehicleJourney < ApplicationRecord
  belongs_to :journey_pattern
  has_many :journey_pattern_sections, through: :journey_pattern
  has_many :journey_pattern_section_maps, through: :journey_pattern

  has_many :journey_pattern_timing_links, through: :journey_pattern_sections
#    insert into vehicle_journeys (line_name, vehicle_journey_code, journey_pattern_ref, journey_pattern_id, days_of_week, departure_time, created_at, updated_at) 
#split_part(SUBSTRING(days_of_week::text, 2, length(days_of_week::text)),' xml',1)
#TO_TIMESTAMP(departure_time::text, 'HH24:MI:SS')
  def self.get_vehicle_journeys
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    puts "book"

    countquery = "select xpath(\'count(//t:VehicleJourney)\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]) from (select * from xmltemp limit 1) as xmltemp"
    #    insert into vehicle_journeys (line_name, vehicle_journey_code, journey_pattern_ref, journey_pattern_id, days_of_week, departure_time, created_at, updated_at) 
    result = rc.exec(countquery)
     result.each do |r|
      puts r
    end
    offset = 0
    while offset < 780
      offset 
      puts "querying"
      match_query = "

      insert into vehicle_journeys (line_name, vehicle_journey_code, journey_pattern_ref, journey_pattern_id, days_of_week,  bh_days_operating,bh_days_not_operating,special_days_starts,special_days_ends, departure_time, created_at, updated_at) 

      select line_name, vehicle_journey_code, grouped_data.journey_pattern_ref, jp.id as journey_pattern_id, days_of_week, bh_days_operating,bh_days_not_operating,special_days_starts,special_days_ends,TO_TIMESTAMP(departure_time::text, 'HH24:MI:SS') as departure_time, NOW(),NOW() from (
      select 
      
      line_name,
      (xpath(\'//t:JourneyPatternRef/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as journey_pattern_ref,
    
      (xpath(\'//t:DepartureTime/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as departure_time,
      (xpath(\'//t:VehicleJourneyCode/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as vehicle_journey_code,
      
      array_remove(array_agg(DISTINCT split_part(SUBSTRING(bh_days_operating::text, 2, length(bh_days_operating::text)),' xml',1)),NULL) as bh_days_operating,
      array_remove(array_agg(DISTINCT split_part(SUBSTRING(bh_days_not_operating::text, 2, length(bh_days_not_operating::text)),' xml',1)),NULL) as bh_days_not_operating,
      array_remove(array_agg(DISTINCT split_part(SUBSTRING(days_of_week::text, 2, length(days_of_week::text)),' xml',1)),NULL) as days_of_week,
      array_remove(array_agg(DISTINCT split_part(SUBSTRING(special_days_starts::text, 2, length(special_days_starts::text)),' xml',1)),NULL) as special_days_starts,
      array_remove(array_agg(DISTINCT split_part(SUBSTRING(special_days_ends::text, 2, length(special_days_ends::text)),' xml',1)),NULL) as special_days_ends
  
      
      from
      (select vj.vehicle_journey, (xpath(\'//t:Services/t:Service/t:Lines/t:Line/t:LineName/text()\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as line_name
      from
      (select * from xmltemp limit 1) as xmltemp 
      cross join lateral unnest(xpath(\'//t:VehicleJourney\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as vj(vehicle_journey)
      
  
      ) as vehicle_journeys
      left join lateral unnest(xpath(\'//t:OperatingProfile/t:RegularDayType/t:DaysOfWeek/*', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as j(days_of_week) on true
      left join lateral unnest(xpath(\'//t:OperatingProfile/t:BankHolidayOperation/t:DaysOfOperation/*\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as l(bh_days_operating) on true
      left join lateral unnest(xpath(\'//t:OperatingProfile/t:BankHolidayOperation/t:DaysOfNonOperation/*\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as m(bh_days_not_operating) on true
      left join lateral unnest(xpath(\'//t:OperatingProfile/t:SpecialDaysOperation/t:DaysOfOperation/t:DateRange/t:StartDate/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as n(special_days_starts) on true
      left join lateral unnest(xpath(\'//t:OperatingProfile/t:SpecialDaysOperation/t:DaysOfOperation/t:DateRange/t:EndDate/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as o(special_days_ends) on true
      
      group by (line_name,journey_pattern_ref,departure_time,vehicle_journey_code)) as grouped_data
      join journey_patterns jp on jp.journey_pattern_ref = grouped_data.journey_pattern_ref
      on conflict (vehicle_journey_code) do nothing
        "
        #puts match_query

        match_query = "
        insert into vehicle_journeys (line_name,vehicle_journey_code, journey_pattern_ref, journey_pattern_id, days_of_week,  bh_days_operating,bh_days_not_operating,special_days_starts,special_days_ends, departure_time, created_at, updated_at) 

        select line_name, vehicle_journey_code, j.journey_pattern_ref, jp.id, 
        array_remove(array_agg(distinct days_of_week),NULL) as days_of_week,

        array_remove(array_agg(distinct bh_days_operating),NULL) as bh_days_operating,
        array_remove(array_agg(distinct bh_days_not_operating),NULL) as bh_days_not_operating,
        array_remove(array_agg(distinct special_days_starts),NULL) as special_days_starts,
        array_remove(array_agg(distinct special_days_ends),NULL) as special_days_ends,
        TO_TIMESTAMP(departure_time::text, 'HH24:MI:SS') as departure_time,
        NOW(),
        NOW()
     from (
          
        select  
        line_name,
        (xpath(\'//t:JourneyPatternRef/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as journey_pattern_ref,
        (xpath(\'//t:DepartureTime/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as departure_time,
        (xpath(\'//t:VehicleJourneyCode/text()\', vehicle_journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as vehicle_journey_code
        from (
          select
          unnest(xpath(\'//t:VehicleJourney\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as vehicle_journey,

          (xpath(\'//t:LineName/text()\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as line_name
          from
            (select * from xmltemp limit 1 offset #{offset}) as xmltemp )
            
            
             as journeys
            ) as j
     

        "
        match_query += {
          "days_of_week": "//t:OperatingProfile/t:RegularDayType/t:DaysOfWeek/*",
          "bh_days_operating": "//t:OperatingProfile/t:BankHolidayOperation/t:DaysOfOperation/*",
          "bh_days_not_operating": "//t:OperatingProfile/t:BankHolidayOperation/t:DaysOfNonOperation/*",
          "special_days_starts": "//t:OperatingProfile/t:SpecialDaysOperation/t:DaysOfOperation/t:DateRange/t:StartDate/text()",
          "special_days_ends": "//t:OperatingProfile/t:SpecialDaysOperation/t:DaysOfOperation/t:DateRange/t:EndDate/text()"
      }.map { |thing, path|
        
       "
         
         left outer join (select journey_code,  split_part(SUBSTRING(#{thing}::text, 2, length(#{thing}::text)),' xml',1) as #{thing}
         from
         (select 
         
          (xpath(\'//t:VehicleJourneyCode/text()\', journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as journey_code,
          unnest(xpath(\'#{path}\', journey, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as #{thing}
         from

         (
          select
          unnest(xpath(\'//t:VehicleJourney\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey
          from (select * from xmltemp limit 1 offset #{offset}) as xmltemp )
          as journeys) as #{thing}alias) as #{thing}_table on #{thing}_table.journey_code = j.vehicle_journey_code "
    }.join(" ")
    match_query += "
    join journey_patterns jp on jp.journey_pattern_ref = j.journey_pattern_ref
    group by line_name, vehicle_journey_code, departure_time, j.journey_pattern_ref, jp.id
    on conflict do nothing
    
    "

      #puts match_query
    result = rc.exec(match_query)
    n = result.cmd_tuples
        #puts result.inspect
     result.each do |r|
        #puts r
     end
     offset += 1
      puts offset
   end
  end

  def xmltable
 " SELECT xmltable.*
    FROM (select * from xmltemp limit 1000) as xmltemp,
         XMLTABLE(XMLNAMESPACES('http://www.transxchange.org.uk/' AS t),
         '//t:TransXChange/t:VehicleJourneys/t:VehicleJourney'
                  PASSING doc
                  COLUMNS vehicle_journey_code text PATH 't:VehicleJourneyCode',
                          departure_time text PATH 't:DepartureTime',
                          journey_pattern_ref text PATH 't:JourneyPatternRef',
                          day_of_week XML PATH 't:OperatingProfile/t:RegularDayType/t:DaysOfWeek');"
;

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
      VehicleJourney.includes(:journey_pattern_section_maps).where('days_of_week @> ARRAY[?]::text[]', dow).where(line_name: line_name).where.not(journey_pattern_id: nil).each do |v|
        

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
