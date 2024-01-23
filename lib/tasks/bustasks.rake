namespace :check do

  desc "check for buses"

  task :bus => :environment do |t, args|
   
    ArrivalUpdate.fetch_updates
  end

  task :locations => :environment do |t, args|
   
    Vehicle.check_locations
  end
end




