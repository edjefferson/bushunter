require 'csv'

class ArrivalUpdate < ApplicationRecord
  def self.update_request(pull_count)
    begin
      ArrivalUpdate.where("created_at < '#{6.hours.ago}'").delete_all
      app_key = ENV['TFL_APP_KEY']
      url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?count=#{pull_count}&app_key=#{app_key}"
      filebody = URI.open(url).read
      
      puts "#{Time.now} request complete, parsing"
      json = JSON.parse(filebody)
      puts json.count
      updates = json.map do |u|
        {
          stop_id: u["naptanId"],
          stop_name: u["stationName"],
          vehicle_id: u["vehicleId"],
          expected_arrival: u["expectedArrival"],
          line_name: u["lineName"],
          timestamp: u["timestamp"]
        }
      end
      self.import updates, on_duplicate_key_ignore: true
      puts "#{Time.now} import complete"
    rescue => e
      puts e
    end
  end

  def self.fetch_updates
    last_time = Time.now - 90
    while true
      if (Time.now() - last_time) > 60
        self.update_request(-1)
        last_time = Time.now
      else
        self.update_request(5)
      end
      
    end
  end
end
