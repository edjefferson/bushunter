require 'open-uri'
require 'rgeo'
class Route < ApplicationRecord

  def self.retrieve_data(line_name,direction)
    url = "https://api.tfl.gov.uk/Line/#{line_name}/Route/Sequence/#{direction}?api_key=#{ENV['TFL_APP_KEY']}"
    puts url
    data = JSON.parse(URI.open(url).read)
    strings = data["lineStrings"].map {|l| JSON.parse(l)}
    route = self.where(line_name: line_name, direction: direction).first_or_create
    route.update(linestrings: strings.to_json)
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
    RGeo::Geographic.spherical_factory.point(p[0],p[1])
      
    }
    #polyline = factory.line_string(line_string_points)


    start_line_point = get_nearest_point_on_route(start)
    end_line_point = get_nearest_point_on_route(finish)
    nearest_to_start_point = nil
    nearest_to_start_point_dist = 9999999
    nearest_to_start_point_index = nil
    line_string_points.each_with_index do |p,i|
      distance = p.distance(start_line_point)
      puts i,distance
      if distance < nearest_to_start_point_dist
        nearest_to_start_point = start_line_point
        nearest_to_start_point_dist = distance
        nearest_to_start_point_index = i 
      end
    end

    nearest_to_end_point = nil
    nearest_to_end_point_dist = 9999999
    nearest_to_end_point_index = nil
    line_string_points.reverse.each_with_index do |p,i|
      distance = p.distance(end_line_point)
      if distance < nearest_to_end_point_dist
        nearest_to_end_point = end_line_point
        nearest_to_end_point_dist = distance
        nearest_to_end_point_index = (line_string_points.count - i) 
      end
    end
    puts nearest_to_start_point_index
    puts nearest_to_end_point_index

    puts nearest_to_end_point_index
    total = nearest_to_start_point.distance(start_line_point)
    line_string_points[nearest_to_start_point_index..nearest_to_end_point_index - 1].each_with_index do |l,i|
      total += l.distance(line_string_points[i+1])
    end
    puts nearest_to_start_point.distance(start_line_point)
    puts nearest_to_end_point.distance(end_line_point)
    total += nearest_to_end_point.distance(end_line_point)
    puts total

  end
end
