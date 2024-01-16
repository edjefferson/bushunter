require 'csv'

class ArrivalUpdate < ApplicationRecord
  def self.update_request(pull_count)
    begin
      app_key = ENV['TFL_APP_KEY']
      url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?count=#{pull_count}&app_key=#{app_key}"
      filebody = URI.open(url).read
      Rails.logger.info "#{Time.now} request complete, parsing"
      puts "#{Time.now} request complete, parsing"
      json = JSON.parse(filebody)
      Rails.logger.info "#{json.count} records parse"
      updates = json.map do |u|
        {
          stop_id: u["naptanId"],
          stop_name: u["stationName"],
          vehicle_id: u["vehicleId"],
          expected_arrival: u["expectedArrival"],
          line_name: u["lineName"],
          timestamp: u["timestamp"],
          platform_name: u["platformName"],
          destination_name: u["destinationName"]
        } 
      end
      puts updates[0]

      self.import updates, on_duplicate_key_ignore: true, batch_size: 5000
      Rails.logger.info "#{Time.now} import complete"
      puts "#{Time.now} import complete"
    rescue => e
      puts e
    end
  end

  def self.fetch_updates
    last_time = Time.now - 90
    while true
      if (Time.now() - last_time) > 60
        ArrivalUpdate.where("created_at < '#{6.hours.ago}'").delete_all
        self.update_request(-1)
        last_time = Time.now
      else
        self.update_request(3)
      end
      
    end
  end
end
