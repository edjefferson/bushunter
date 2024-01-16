require 'csv'

class ArrivalUpdate < ApplicationRecord
  def self.update_request(pull_count,last_updates)
    begin
      app_key = ENV['TFL_APP_KEY']
      url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?count=#{pull_count}&app_key=#{app_key}"
      filebody = URI.open(url).read
      logger.info "#{Time.now} request complete, parsing"
      puts "#{Time.now} request complete, parsing"
      json = JSON.parse(filebody)
      logger.info "#{json.count} records parse"
      updates = json.map do |u|
        {
          stop_id: u["naptanId"],
          stop_name: u["stationName"],
          vehicle_id: u["vehicleId"],
          expected_arrival: u["expectedArrival"],
          line_name: u["lineName"],
          platform_name: u["platformName"],
          destination_name: u["destinationName"],
          timestamp: u["timestamp"]
        } 
      end
      puts "#{updates.count} records before dedupe"

      updates.uniq! {|b| [b[:stop_id],b[:vehicle_id]]}
      puts "#{updates.count} records before 2nd dedupe"
      if last_updates[0]
        updates = updates - last_updates
      end
      puts "#{updates.count} records after dedupe"
      updates.uniq!
      self.upsert_all(updates, unique_by: [:vehicle_id,:stop_id])

      logger.info "#{Time.now} import complete"
      puts "#{Time.now} import complete"
      
      return updates + last_updates
    rescue => e
      puts e
      return last_updates
    end
  end

  def self.fetch_updates
    last_time = Time.now - 90
    last_updates = []
    while true
      if last_updates.count >= 250000
        last_updates.shift(50000)
      end
      if (Time.now() - last_time) > 60
        ArrivalUpdate.where("created_at < '#{40.minutes.ago}'").delete_all
        last_updates = self.update_request(-1,last_updates)
        last_time = Time.now
      else
        last_updates = self.update_request(5,last_updates)
      end
      
    end
  end
end
