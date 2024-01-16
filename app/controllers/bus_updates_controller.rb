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
    stop_letter = ""
    @updates = ArrivalUpdate.where(stop_id: params[:stop_id], timestamp: (Time.now-30.minutes)..).order(timestamp: :desc)
    puts @updates[0].inspect
    @vehicles = @updates.map{|u|  u.vehicle_id}
    puts @updates.map{|u|  u.vehicle_id}
    @vehicles = [] unless @vehicles
    @data = @vehicles.uniq.map { |v|
      puts v
      last_update = @updates.where(vehicle_id: v).where.not(expected_arrival: nil).order(timestamp: :desc)[0]
      if (last_update)
        stop_name = last_update.stop_name
        stop_letter = last_update.platform_name
        {
          line_name: last_update.line_name,
          timestamp: last_update.timestamp,
          expected_arrival: last_update.expected_arrival,
          projected_tts: (last_update.expected_arrival - Time.now),
          vehicle_id: last_update.vehicle_id,
          destination_name: last_update.destination_name
        }
      end
      }
      
    
    render :json => {
      time_now: Time.now.to_i,
      stop_name: stop_name,
      stop_letter: stop_letter,
      buses: @data.sort_by {|d| d[:projected_tts]}
    }
  end
end
