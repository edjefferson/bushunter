require 'open-uri'

class StopPoint < ApplicationRecord

  def self.get_stop_points

    json = JSON.parse(URI.open("https://api.tfl.gov.uk/Line/Mode/bus").read)

    json.each do |line|
      puts line["name"]
      ["inbound","outbound"].each do |direction|
        puts "https://api.tfl.gov.uk/Line/#{line["name"]}/Route/Sequence/#{direction}"

        linejson = JSON.parse(URI.open("https://api.tfl.gov.uk/Line/#{line["name"]}/Route/Sequence/#{direction}").read)
        data = []
        seqs = linejson["stopPointSequences"].map do |seq|
          seq["stopPoint"].each do |stat|
            #puts stat["name"]
            stat_info = {
              stop_id: stat['id'],
              name: stat['name'],
              lat: stat['lat'],
              lng: stat['lon'],
            }
            data << stat_info unless data.include?(stat_info)
          end
        end
        #puts data[0].inspect
        #sleep 100
        self.import data, on_duplicate_key_ignore: true

      end
    end
  end
end
