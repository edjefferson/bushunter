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
    puts "egg"

    factory = RGeo::Geos.factory(:native_interface => :ffi)
    line_string_points = JSON.parse(self.linestrings)[0][0].map {|p| factory.point(p[0],p[1])}

    polyline = factory.line_string(line_string_points)
    puts polyline
    point = factory.point(point[1],point[0])

    low_level_polyline = polyline.fg_geom
    low_level_point = point.fg_geom

    dist = low_level_polyline.project(low_level_point)
    low_level_closest_point = low_level_polyline.interpolate(dist)

    closest_point = factory.wrap_fg_geom(low_level_closest_point) 
    return closest_point
  end

  def get_distance_between_two_points(start,finish)

    factory = RGeo::Geos.factory(:native_interface => :ffi)
    line_string_points = JSON.parse(self.linestrings)[0][0].map {|p| factory.point(p[0],p[1])}
    polyline = factory.line_string(line_string_points)

    
    start_line_point = get_nearest_point_on_route(start)
    end_line_point = get_nearest_point_on_route(finish)
  end
end
