
require 'open-uri'
require 'json'
require 'active_record'
require 'activerecord-import'


desc "check for buses"
task :check_bus => :environment do
  ArrivalUpdate.where(created_at: ..Time.now - 6.hours).delete_all
  app_key = ENV["TFL_APP_KEY"]

  last_time = Time.now
  stop_id = "490006566N"
  (1..6).each do |x|
    puts "checking #{stop_id} at #{Time.now}"
    Rails.logger.info "checking #{stop_id} at #{Time.now}"
    surl = "https://api.tfl.gov.uk/StopPoint/#{stop_id}/Arrivals?app_key=#{app_key}"
    sjson = JSON.parse(URI.open(surl).read)
    vehicleIds = []

    updates = sjson.map do |s|
       {
        stop_id: s["naptanId"],
        stop_name: s["stationName"],
        vehicle_id: s["vehicleId"],
        time_to_station: s["timeToStation"],
        line_name: s["lineName"],
        timestamp: s["timestamp"]
      }
    end
    


    ArrivalUpdate.import updates, on_duplicate_key_ignore: true
    if (10 - (Time.now - last_time) > 0)
      sleep 10 - (Time.now - last_time)
    end
    last_time = Time.now

  end
end




