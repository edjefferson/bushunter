class BusUpdatesController < ApplicationController

 

  def nearby_stops
    data = StopPoint.near([params[:lat],params[:lng]], 1, units: :km)
    finaldata = data.map {|d| 
      json = d.as_json
      json[:dist] = d.distance_from([params[:lat],params[:lng]])
      json
    }
    render :json => finaldata
    
  end

  def live_update
    stop_name = ""
    @updates = ArrivalUpdate.where(stop_id: params[:stop_id], timestamp: (Time.now-60.minutes)..).order(timestamp: :desc)
    @vehicles = @updates.map{|u|  u.vehicle_id}.uniq!
    @vehicles = [] unless @vehicles
    @data = @vehicles.map { |v|
      last_update = @updates.where(vehicle_id: v).where.not(expected_arrival: nil).order(timestamp: :desc)[0]
      if (last_update)
        stop_name = last_update.stop_name
        {
          line_name: last_update.line_name,
          timestamp: last_update.timestamp,
          expected_arrival: last_update.expected_arrival,
          projected_tts: (last_update.expected_arrival - Time.now),
          vehicle_id: last_update.vehicle_id
        }
      end
      }
      
    
    render :json => {
      time_now: Time.now.to_i,
      stop_name: stop_name,
      buses: @data.sort_by {|d| d[:projected_tts]}
    }
  end
end
