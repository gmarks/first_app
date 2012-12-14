require 'rubygems'
require 'google/api_client'
require 'json'
require 'date'

#$PROFILE_ID = 60102324
#$PARTY_ID = 4158170

# Credentials can be obtained @ https://code.google.com/apis/console/ under "API Access"
$CLIENT_ID = '1096301339654.apps.googleusercontent.com'
$CLIENT_SECRET = 'u77nI4qbHg_4-brnX-QBH6FR'
# This can be obtained @ https://code.google.com/oauthplayground
$REFRESH_TOKEN = '1/fql3tgW3w7uMtuVI-sC_Lr2ufT4wxNIY3JEvSnQAWAo'

@client = Google::APIClient.new
@client.authorization.client_id = $CLIENT_ID
@client.authorization.client_secret = $CLIENT_SECRET
@client.authorization.scope = 'https://www.google.com/apis/ads/publisher'

@client.authorization.refresh_token = $REFRESH_TOKEN
@client.authorization.fetch_access_token!

@api = @client.discovered_api('analytics', 'v3')

month_ago = (Date.today << 1).strftime('%Y-%m-%d')
today = Date.today.strftime('%Y-%m-%d')

response = @client.execute(
    :api_method => @api.data.ga.get,
    :parameters => {'start-date' => month_ago,
                    'end-date' => today,
                    :ids => "ga:#{$PROFILE_ID}",
                    :metrics => "ga:visits",
                    :dimensions => 'ga:pagePath',
                    :filters => "ga:pagePath=~#{$PARTY_ID}d"}
)
response_json = JSON.parse(response.data.to_json)

puts "Response:"
puts response_json

puts "\n============"
puts "Total visits:"
puts response_json['totalsForAllResults']['ga:visits'] rescue "N/A"

if response_json['rows']
  puts "\n============"
  puts "Individual rows:"
  response_json['rows'].each do |row|
    puts "URL: #{row[0]} = #{row[1]}"
  end
end



