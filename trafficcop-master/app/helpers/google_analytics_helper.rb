require 'rubygems'
require 'google/api_client'
require 'json'
require 'date'

module GoogleAnalyticsHelper

  PROFILE_ID = 14168817

  # Credentials can be obtained @ https://code.google.com/apis/console/ under "API Access"
  CLIENT_ID = '1096301339654.apps.googleusercontent.com'
  CLIENT_SECRET = 'u77nI4qbHg_4-brnX-QBH6FR'


  REFRESH_TOKEN = '1/fql3tgW3w7uMtuVI-sC_Lr2ufT4wxNIY3JEvSnQAWAo'

  def self.get_client
    client = Google::APIClient.new
    client.authorization.client_id = CLIENT_ID
    client.authorization.client_secret = CLIENT_SECRET
    client.authorization.scope = 'https://www.googleapis.com/auth/analytics'

    client.authorization.refresh_token = REFRESH_TOKEN
    client.authorization.fetch_access_token!

    client
  end

  def self.page_views_by_city_and_state(city,state)
    client = get_client
    city = city.gsub(" ","_")
    api = client.discovered_api('analytics', 'v3')
    month_ago = (Date.today << 1).strftime('%Y-%m-%d')
    today = Date.today.strftime('%Y-%m-%d')
    puts "PAGEPATH:  #{state}/#{city}/.*d_.*"

    response = client.execute(
      :api_method => api.data.ga.get,
      :parameters => {'start-date' => month_ago,
                      'end-date' => today,
                      :ids => "ga:#{PROFILE_ID}",
                      :metrics => "ga:visits,ga:pageviews",
                      :dimensions => 'ga:pagePath',
                      :filters => "ga:pagePath=~/#{state}/#{city}/.*d_.*"}
    )
    response_json = JSON.parse(response.data.to_json)
    response = { :page_views => response_json['totalsForAllResults']['ga:pageviews'],
                 :page_visits => response_json['totalsForAllResults']['ga:visits'],
                 }

    response
  end


end
