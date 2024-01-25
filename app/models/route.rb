require 'open-uri'
require 'rgeo'

class RouteCoords
  attr_accessor :coordinates
  def initalize params
    @coordinates = []
  end
end

class Route < ApplicationRecord

  def self.retrieve_data(line_name,direction)
    url = "https://api.tfl.gov.uk/Line/#{line_name}/Route/Sequence/#{direction}?api_key=#{ENV['TFL_APP_KEY']}"
    puts url
    data = JSON.parse(URI.open(url).read)
    strings = data["lineStrings"].map {|l| JSON.parse(l)}
    route = self.where(line_name: line_name, direction: direction).first_or_create
    route.update(linestrings: strings.to_json)
    route
  end

  def get_nearest_point_on_route(point)
    #puts "egg"

    factory = RGeo::Geos.factory(:native_interface => :ffi)
    line_string_points = JSON.parse(self.linestrings)[0][0].map {|p| factory.point(p[0],p[1])}

    polyline = factory.line_string(line_string_points)
    #puts polyline
    point = factory.point(point[1],point[0])

    low_level_polyline = polyline.fg_geom
    low_level_point = point.fg_geom

    dist = low_level_polyline.project(low_level_point)
    low_level_closest_point = low_level_polyline.interpolate(dist)

    closest_point = factory.wrap_fg_geom(low_level_closest_point) 
    return closest_point
  end

  def get_distance_between_two_points(start,finish)
    line_string_points = JSON.parse(self.linestrings)[0][0].map {|p| 
      r = RouteCoords.new
      r.coordinates = p
      r
    }


    start_line_point = get_nearest_point_on_route(start)
    end_line_point = get_nearest_point_on_route(finish)
    nearest_to_start_point = nil
    nearest_to_start_point_dist = 9999999
    nearest_to_start_point_index = nil
    line_string_points.each_with_index do |p,i|

      distance = Geocoder::Calculations.distance_between(p.coordinates.reverse,start_line_point.coordinates.reverse)
      if distance < nearest_to_start_point_dist
        nearest_to_start_point = p
        nearest_to_start_point_dist = distance
        nearest_to_start_point_index = i 
      end
    end

    bearing =  Geocoder::Calculations.bearing_between(start_line_point.coordinates.reverse,nearest_to_start_point.coordinates.reverse)

    line_bearing = Geocoder::Calculations.bearing_between(nearest_to_start_point.coordinates.reverse,line_string_points[nearest_to_start_point_index].coordinates.reverse)
    
    distance = Geocoder::Calculations.distance_between(nearest_to_start_point.coordinates.reverse,start_line_point.coordinates.reverse)
    if (bearing - line_bearing).abs < 1
      total = - distance
    else
      total = distance
    end

    nearest_to_end_point = nil
    nearest_to_end_point_dist = 9999999
    nearest_to_end_point_index = nil
    line_string_points.reverse.each_with_index do |p,i|

      distance = Geocoder::Calculations.distance_between(p.coordinates.reverse,end_line_point.coordinates.reverse)

      if distance < nearest_to_end_point_dist
        nearest_to_end_point = p
        nearest_to_end_point_dist = distance
        nearest_to_end_point_index = (line_string_points.count - i - 1) 
      end
    end

   
    bearing =  Geocoder::Calculations.bearing_between(nearest_to_end_point.coordinates.reverse,end_line_point.coordinates.reverse)
    line_bearing = Geocoder::Calculations.bearing_between(line_string_points[nearest_to_end_point_index-1].coordinates.reverse,nearest_to_end_point.coordinates.reverse)
    distance = Geocoder::Calculations.distance_between(nearest_to_end_point.coordinates.reverse,end_line_point.coordinates.reverse)

    
    if (bearing - line_bearing).abs < 1
      total += distance
    else
      total -= distance
    end
    subsection = line_string_points[nearest_to_start_point_index..nearest_to_end_point_index]
    if nearest_to_start_point_index != nearest_to_end_point_index
      subsection.each_with_index do |l,i|
        if i < subsection.length - 1
          total += Geocoder::Calculations.distance_between(l.coordinates.reverse,subsection[i+1].coordinates.reverse)
        end
      end
    end
  
    return total
  end
end
