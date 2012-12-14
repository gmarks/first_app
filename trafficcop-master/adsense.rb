require 'rubygems'
require 'google/api_client'
require 'json'
require 'date'

# Credentials can be obtained @ https://code.google.com/apis/console/ under "API Access"
$CLIENT_ID = '678248260842.apps.googleusercontent.com'
$CLIENT_SECRET = 'bcFeg89T-KwnF-6Z0t_cg4Z9'
# This can be obtained @ https://code.google.com/oauthplayground
$REFRESH_TOKEN = '1/xjxZCJwCQp3uK6KK6zYoi9NpKfCubcld8bjhO12ouII'

@client = Google::APIClient.new
@client.authorization.client_id = $CLIENT_ID
@client.authorization.client_secret = $CLIENT_SECRET
@client.authorization.scope = 'https://www.googleapis.com/auth/adsense'

@client.authorization.refresh_token = $REFRESH_TOKEN
@client.authorization.fetch_access_token!

@api = @client.discovered_api('adsense')

yesterday = (Date.today - 1).strftime('%Y-%m-%d')
response = @client.execute(
  :api_method => @api.reports.generate,
  :parameters => {:startDate => yesterday, :endDate => yesterday, :metric => "TOTAL_EARNINGS"}
)
puts "Total yesterday's earnings: #{JSON.parse(response.data.to_json)["totals"]}"



