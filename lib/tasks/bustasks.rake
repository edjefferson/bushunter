
require 'open-uri'
require 'json'
require 'active_record'
require 'activerecord-import'


desc "check for buses"
task :check_bus => :environment do
  ArrivalUpdate.where(created_at: Time.now - 6.hours..).delete_all
  app_key = ENV["TFL_APP_KEY"]

  line = "W19"

  inout = "inbound"

  stopsurl = "https://api.tfl.gov.uk/Line/#{line}/Route/Sequence/#{inout}?app_key=#{app_key}"

  stopsjson = JSON.parse(URI.open(stopsurl).read)

  stops = stopsjson["stopPointSequences"][0]["stopPoint"].map { |s|
    [s["id"],s["name"]]  
  }
  last_time = Time.now
  stop_id = "490006566N"
  (1..6).each do |x|
    url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?app_key=#{app_key}"
    surl = "https://api.tfl.gov.uk/StopPoint/#{stop_id}/Arrivals?app_key=#{app_key}"
    json = JSON.parse(URI.open(url).read)
    sjson = JSON.parse(URI.open(surl).read)
    vehicleIds = []

    sjson.each do |v|
      vehicleIds << v["vehicleId"]
    end
    stops.each do |s|
      json.select {|j| j["naptanId"] == s[0] && j["lineName"] == "W19"}.each do |v|
        vehicleIds << v["vehicleId"]
      end
    end

    vehicleIds.uniq!
    if (vehicleIds)
      puts "checking #{vehicleIds.join(",")} at #{Time.now}"
      Rails.logger.info "checking #{vehicleIds.join(",")} at #{Time.now}"

      updates = []
      
      url = "https://api.tfl.gov.uk/Vehicle/#{vehicleIds.join(",")}/Arrivals?app_key=#{app_key}"
      json = JSON.parse(URI.open(url).read)

      stops.each do |s|
        
        json.select {|j| j["naptanId"] == s[0] && j["lineName"] == "W19"}.each do |v|
          arrivalupdate = {
            stop_id: s[0],
            stop_name: s[1],
            vehicle_id: v["vehicleId"],
            time_to_station: v["timeToStation"],
            line_name: v["lineName"],
            timestamp: v["timestamp"]
        }
          updates << arrivalupdate
        end
      end

      ArrivalUpdate.import updates, on_duplicate_key_ignore: true
      if (10 - (Time.now - last_time) > 0)
        sleep 10 - (Time.now - last_time)
      end
      last_time = Time.now
    end
  end
end




