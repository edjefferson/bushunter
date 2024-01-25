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
    stop_loc = []
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
        vehicle_records = Vehicle.where(vehicle_ref:last_update.vehicle_id).order(recorded_at: :desc)
        stop_record = StopPoint.find_by(stop_id: params[:stop_id])
        stop_loc = [stop_record.lat,stop_record.lng]
        if vehicle_records[0] && stop_record
          vehicle_distance = Geocoder::Calculations.distance_between([vehicle_records[0].latitude,vehicle_records[0].longitude], [stop_record.lat,stop_record.lng])
          vehicle_speeds = []
          route = Route.where(direction: last_update.direction, line_name: last_update.line_name)[0]
       
          vehicle_records.each_with_index do |vehicle_record,i|
            if route && i < vehicle_records.length - 2
              last_record = vehicle_records[i+1]
              distance = route.get_distance_between_two_points([vehicle_record.latitude,vehicle_record.longitude],[last_record.latitude,last_record.longitude])
              time = vehicle_record.recorded_at - last_record.recorded_at
              vehicle_speeds << (distance/time).abs * 1.60934 * 1000
            end
          end
        else
          vehicle_distance = nil
          vehicle_speeds = []
        end
        {
          vehicle_speeds: vehicle_speeds,
          vehicle_loc: [vehicle_records[0].latitude,vehicle_records[0].longitude],
          bearing: vehicle_records[0].bearing,
          loc_update_time: vehicle_records[0].recorded_at,
          line_name: last_update.line_name,
          timestamp: last_update.timestamp,
          expected_arrival: last_update.expected_arrival,
          projected_tts: (last_update.expected_arrival - Time.now),
          vehicle_id: last_update.vehicle_id,
          destination_name: last_update.destination_name,
          vehicle_distance: vehicle_distance
        }
      end
      }
      
    
    render :json => {
      stop_loc: stop_loc,
      time_now: Time.now.to_i,
      stop_name: stop_name,
      stop_letter: stop_letter,
      buses: @data.sort_by {|d| d[:projected_tts]}
    }
  end
end
