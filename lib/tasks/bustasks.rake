namespace :check do

  desc "check for buses"

  task :bus => :environment do |t, args|
    begin
      ArrivalUpdate.fetch_updates
    rescue => e
      sleep 10
      retry
    end
  end

  task :locations => :environment do |t, args|
    begin
      Vehicle.check_locations
    rescue => e
      sleep 10
      retry
    end
  end
end




