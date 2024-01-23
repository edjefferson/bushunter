class JourneyPatternSectionMap < ApplicationRecord
  belongs_to :journey_pattern
  belongs_to :journey_pattern_section

  def self.fetch_data_from_xml
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    
    match_query = "
    insert into journey_pattern_section_maps (journey_pattern_section_ref,journey_pattern_ref, created_at,updated_at)

    select journey_pattern_section_ref,journey_pattern_ref, NOW(),NOW() from
  
    
   (select
   unnest(xpath(\'//t:JourneyPatternSectionRefs/text()\', journey_patterns, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))::text as journey_pattern_section_ref, 
   (xpath(\'//@id\', journey_patterns, array[array[\'t\',\'http://www.transxchange.org.uk/\']]))[1]::text  as journey_pattern_ref
    from
    (select
    unnest(xpath(\'//t:JourneyPattern\', doc, array[array[\'t\',\'http://www.transxchange.org.uk/\']])) as journey_patterns
    from xmltemp) as journey_patterns group by journey_pattern_section_ref,journey_pattern_ref) as grouped"
    result = rc.exec(match_query)
    puts result.inspect
    
    self.get_references
  end

  def self.get_references
    JourneyPatternSection.populate_table
    JourneyPattern.populate_table

    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
    rc.exec("update journey_pattern_section_maps jpm
    set journey_pattern_id = jp.id  
    from journey_patterns jp
    where jp.journey_pattern_ref = jpm.journey_pattern_ref")

    rc.exec("update journey_pattern_section_maps jpm
    set journey_pattern_section_id = js.id  
    from journey_pattern_sections js
    where js.journey_pattern_section_ref = jpm.journey_pattern_section_ref")
    
    
  end
end
