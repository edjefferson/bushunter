class BusUpdatesController < ApplicationController
  def live_update
    stop_name = "Empress Avenue"
    @updates = ArrivalUpdate.where(stop_name: stop_name, timestamp: Time.now-30.minutes..).order(timestamp: :desc)
    @vehicles = @updates.map{|u|  u.vehicle_id}.uniq!
    @vehicles = [] unless @vehicles
    @data = @vehicles.map { |v|
      last_update = @updates.where(vehicle_id: v).order(timestamp: :desc)[0]
      if (last_update)
        projected_arrival = last_update.timestamp + last_update.time_to_station
        {
          line_name: last_update.line_name,
          timestamp: last_update.timestamp,
          time_to_station: last_update.time_to_station/60,
          projected_arrival: projected_arrival,
          projected_tts: (projected_arrival - Time.now)/60,
          vehicle_id: last_update.vehicle_id
        }
      end
      }
      
    
    render :json => {
      stop_name: stop_name,
      buses: @data.sort_by {|d| d[:projected_tts]}
    }
  end
end
