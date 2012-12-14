require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_apps, :store => OpenID::Store::Filesystem.new('./tmp'), :domain => "homefinder.com", :name => 'admin'
  # provider :developer unless Rails.env.production?
  # provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end