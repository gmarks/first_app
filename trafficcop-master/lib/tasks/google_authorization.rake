task :seed_google_auth => :environment do
  puts "Seeding the google app." 
  auth = GoogleAuthToken.all
  if auth
    auth.each do |a|
      p "Destroying the current auth."
      a.destroy
    end
  end
  new_auth = GoogleAuthToken.new
  new_auth.refresh_token = Trafficcop::Application::GOOGLE_REFRESH_TOKEN
  new_auth.token_expires_in  = -1   # This will force new call to get a new access_token when calling the google api.
  new_auth.save
end