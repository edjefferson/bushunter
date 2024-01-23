class JourneyPatternSectionMap < ApplicationRecord
  belongs_to :journey_pattern
  belongs_to :journey_pattern_section

  def self.fetch_data_from_xml
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    
    match_query = "
    insert into journey_pattern_section_maps (journey_pattern_section_ref,journey_pattern_ref, created_at,updated_at)

    select journey_pattern_section_ref,journey_pattern_ref, NOW(),NOW() from
    (select unnest(xpath(\'//t:JourneyPatternSectionRefs/text()\', journey_patterns, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))::text as journey_pattern_section_ref, 
    
    unnest(xpath(\'//@id\', journey_patterns, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))::text as journey_pattern_ref
    from
    (select
    unnest(xpath(\'//t:JourneyPattern\', service, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey_patterns from
    (select line_name, unnest(xpath(\'//t:Service\', timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))  as service
    from
    (select timetable, unnest(xpath(\'//t:LineName/text()\' , timetable, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as line_name
    from 
    (select unnest(xpath(\'//t:TransXChange\' , doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']]) ) as timetable   from xmltemp) as timetables) as timetables2) as servicedata) as journeypatternsdata group by journey_pattern_ref, journey_pattern_section_ref ) as grouped  "
    result = rc.exec(match_query)
    puts result.inspect
    
    
  end

  def self.get_references

    "
    update journey_pattern_section_maps jpm
    set journey_pattern_id = jp.id  
    from journey_patterns jp
    where jp.journey_pattern_ref = jpm.journey_pattern_ref
    
    "

    "
    update journey_pattern_section_maps jpm
    set journey_pattern_section_id = js.id  
    from journey_pattern_sections js
    where js.journey_pattern_section_ref = jpm.journey_pattern_section_ref
    
    "
  end
end
