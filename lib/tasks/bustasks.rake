namespace :check do

  desc "check for buses"

  task :bus => :environment do |t, args|
   
    ArrivalUpdate.fetch_updates
  end
end




