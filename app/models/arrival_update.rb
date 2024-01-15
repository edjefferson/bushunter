require 'csv'

class ArrivalUpdate < ApplicationRecord
  def self.update_request(hydra)
    app_key = ENV['TFL_APP_KEY']
    url = "https://api.tfl.gov.uk/Mode/bus/Arrivals?count=-1&app_key=#{app_key}"
    request = Typhoeus::Request.new(url)
    request.on_complete do |response|
      puts "#{Time.now} request complete, parsing"
      json = JSON.parse(URI.open(url).read)
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
      puts hydra.queued_requests.length
      self.update_request(hydra)
    end
    hydra.queue(request)
    return hydra
  end

  def self.fetch_updates
    hydra = Typhoeus::Hydra.new(max_concurrency: 4)

    5.times do 
      hydra = self.update_request(hydra)
    end
    hydra.run
    ArrivalUpdate.where("created_at < '#{6.hours.ago}'").delete_all
  end
end
