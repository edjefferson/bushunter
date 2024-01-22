class JourneyPatternTimingLink < ApplicationRecord
  belongs_to :journey_pattern_section

  def self.fetch_data_from_xml
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection

    match_query = """
    insert into journey_pattern_timing_links (from_stop,to_stop,run_time,wait_time, journey_pattern_timing_link_ref,journey_pattern_section_id, created_at,updated_at)
  
    select (xpath(\'//t:From/t:StopPointRef/text()\' , jptl, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as from,
    (xpath(\'//t:To/t:StopPointRef/text()\' , jptl, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as to,
    (xpath(\'//t:RunTime/text()\' , jptl, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text::interval as run_time,
    (xpath(\'//t:WaitTime/text()\' , jptl, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text::interval as wait_time,
    (xpath(\'//@id\' , jptl, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text as journey_pattern_timing_link_ref,

    jps.id as journey_pattern_section_id, NOW(),NOW() from
    (select journey_pattern_section_ref, unnest(xpath(\'//t:JourneyPatternTimingLink\' , jps, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as jptl
    from (select line_name, unnest(xpath(\'//t:JourneyPatternSection\', tt, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))  as jps,
    unnest(xpath(\'//t:JourneyPatternSection/@id\' , tt, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey_pattern_section_ref
    from (select timetable as tt, unnest(xpath(\'//t:LineName/text()\' , timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as line_name
    from (select unnest(xpath(\'//t:TransXChange\' , doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]) ) as timetable   from xmltemp ) as timetables) as timetables2) as jpslist) as final_data 
    join journey_pattern_sections jps on final_data.journey_pattern_section_ref::text = jps.journey_pattern_section_ref
    ON CONFLICT (journey_pattern_timing_link_ref) DO NOTHING
    "
    
    result = rc.exec(match_query)
    result.each do |r|
      puts r
    end

    puts result.inspect
 
  end

  def self.complete_journey_complete_query


      conn = ActiveRecord::Base.connection
      rc = conn.raw_connection

      match_query = "
      update journey_pattern_timing_links jptm
      set total_time_since_start = arrivals.total_time_since_start
      from (
        select id, (SUM(COALESCE(run_time,\'PT0S\'::interval) + COALESCE(wait_time,\'PT0S\'::interval)) OVER (PARTITION BY (jpm.journey_pattern_section_id) ORDER BY jpm.journey_pattern_section_id ROWS UNBOUNDED PRECEDING)) AS total_time_since_start 
        from journey_pattern_timing_links jpm
        ) as arrivals
      where arrivals.id = jptm.id
      "
      
      

      result = rc.exec(match_query)
      result.each do |r|
        puts r
      end

      puts result.inspect
    
  end
end

