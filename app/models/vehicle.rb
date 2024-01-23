require 'open-uri'
class Vehicle < ApplicationRecord

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
        bearing: v.css("Bearing").inner_text.strip
      }
    }
    self.upsert_all(update, unique_by: :vehicle_ref)
  end
end
