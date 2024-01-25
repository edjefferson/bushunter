require 'open-uri'


class Vehicle < ApplicationRecord


  def self.check_locations
    last_time = Time.now - 90
    continue = true
    while continue
      begin
        if (Time.now - last_time) > 10
          logger.info "#{"checking locations"}"
          puts "#{"checking locations"}"
          last_time = Time.now
          self.pull_data
        end
      rescue => e
        logger.info "#{e}"
        puts "#{e}"
        sleep 10
      end
    end
  end

  def self.pull_data
    url = "https://data.bus-data.dft.gov.uk/api/v1/datafeed/?operatorRef=TFLO&api_key=#{ENV["DFT_API_KEY"]}"
    data = URI.open(url)
    xml = Nokogiri::XML(data)
    update = xml.css("VehicleActivity").map {|v|
      {
        line_name: v.css("PublishedLineName").inner_text.strip,
        vehicle_ref: v.css("VehicleRef").inner_text.strip,
        latitude: v.css("VehicleLocation > Latitude").inner_text.strip,
        longitude: v.css("VehicleLocation > Longitude").inner_text.strip,
        bearing: v.css("Bearing").inner_text.strip,
        recorded_at: v.css("RecordedAtTime").inner_text.strip
      }
    }
    self.upsert_all(update, unique_by: [:vehicle_ref, :recorded_at])
    conn = ActiveRecord::Base.connection
    rc = conn.raw_connection
   
    delete_query = "delete from vehicles where id in (
      SELECT
          id
      FROM
          (
              SELECT
                  *,
                  ROW_NUMBER() OVER (PARTITION BY v.vehicle_ref ORDER BY v.recorded_at desc) as rowcount
              FROM
                  vehicles v 
          ) sub
      WHERE sub.rowcount  > 5)"
      rc.exec(delete_query)
  end
end
