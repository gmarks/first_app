desc "This task is called by the Heroku scheduler add-on"

task :get_mtd_leads => :environment do
    Party.get_mtd_leads
end