require 'google/api_client'
require 'gattica'
require 'open-uri'
require 'net/https'
require 'adwords_api'
require "dfp_api"

class Party < ActiveRecord::Base
  serialize :recurly_addon_array, Array

  has_many :buyer_leads_zip_codes
  has_many :zip_codes, :through => :buyer_leads_zip_codes

  validates_presence_of :name, :hf_party_id

  def total_unique_leads
    ((self.mtd_unique_calls || 0) + (self.mtd_unique_emails || 0)).to_i
  end
  
  def get_party_info_from_hf
    #get the parties
    self.hf_party_id.strip! 
    url =  "http://api.homefinder.com/partyServices/details?id=#{self.hf_party_id}"
    puts url
    results =""
    open(url) do |f|
      results = f.read
    end
    parties_hash = JSON.parser.new(results,{}).parse
    puts y parties_hash
    if parties_hash["status"]["code"].to_i == 200
        if parties_hash["data"]["parties"] && parties_hash["data"]["meta"]["totalMatched"].to_i > 0
          party = parties_hash["data"]["parties"][self.hf_party_id]
          self.hf_party_type = party["type"]
          self.name = party["name"]
          self.hf_party_image_url = party["largeLogoUrl"]
          self.hf_party_page = party["listingsUrl"]
#          self.website = party["siteUrl"]
        else
          puts "CAN'T FIND PARTY ID!"
#          self.errors.add(:hf_party_id, "Can't Find That PartyId in HomeFinder Records")
        end
    end
    self
  end
  
  def self.get_party_info_from_hf
    Party.all.each do |party|
      party.get_party_info_from_hf
      party.save!
    end
  end
  
  def get_mtd_leads
#    start_date = (self.next_billing_date - 1.month).strftime("%Y-%m-%d")
    if !self.next_billing_date
      #just do mtd
      report_date = CGI::escape("#{Date.today.year}-#{Date.today.month} TO #{Date.today.year}-#{Date.today.month}")
      start_date = Date.parse("#{Date.today.year}-#{Date.today.month}-01")
    else
      report_date = CGI::escape("#{(Date.today - 1.month).year}-#{(Date.today - 1.month).month} TO #{Date.today.year}-#{Date.today.month}")
      start_date = self.next_billing_date - 1.month
    end
    url = "https://api.homefinder.com/reportServices/advertiserConsumerSiteReports?reportDate=#{report_date}&advertiserId=#{self.hf_party_id}&returnAllLeadDetails=true&returnAllPackages=true&returnTotal=true"
    puts url
    results =""
    open(url) do |f|
      results = f.read
    end
    result_hash = JSON.parser.new(results,{}).parse
    puts y result_hash
    hard_leads_hash = {:calls => [], :emails => []}
    leads_hash = {}
    if result_hash["status"]["code"].to_i == 200
      if result_hash["data"] && result_hash["data"]["total"] && result_hash["data"]["total"]["leads"]
        leads_hash = result_hash["data"] 
        self.mtd_emails = 0
        if leads_hash["total"]["leads"]["email"]
          emailer_array = []
          leads_hash["allEmailLeadDetails"].each do |email|
            if !email["consumerEmailAddress"].downcase.include?("homefinder.com") && (Time.parse(email["submittedDateTime"]) > start_date)
              self.mtd_emails += 1 
              emailer_array << email["consumerEmailAddress"].downcase
              hard_leads_hash[:emails] << email
            end
          end
          self.mtd_unique_emails = emailer_array.uniq.size
        end
        self.mtd_calls = 0
        if leads_hash["total"]["leads"]["tollFree"]
          caller_array = []
          leads_hash["allTollFreeLeadDetails"].each do |call|
              if !call["callersPhone"].downcase.include?("312601") && (Time.parse(call["submittedDateTime"]) > start_date)
                self.mtd_calls += 1 
                caller_array << call["callersPhone"].downcase
                hard_leads_hash[:calls] << call
              end
          end
          puts y caller_array.uniq
          self.mtd_unique_calls = caller_array.uniq.size
        end

        puts "Added #{self.mtd_emails} email leads and #{self.mtd_calls} call leads for #{self.name}"
      else
        self.mtd_emails = 0
        self.mtd_calls = 0
      end
      self.save!
    else
      raise "API CALL TO HF FAILED"
    end
#    puts y leads_hash
    hard_leads_hash
  end
  
  def recurly_account
    recurly_account = nil
    begin
      puts "LOOKING FOR RECURLY ACCOUNT"
      self.alternate_recurly_account_code = nil if self.alternate_recurly_account_code.blank?
      recurly_account = Recurly::Account.find(self.alternate_recurly_account_code || self.hf_party_id)
    rescue Recurly::Resource::NotFound => e
      #person does not have recurly account yet, or it's not on HF party id
      puts "DID NOT FIND RECURLY ACCOUNT"
    end
    recurly_account
  end
  
  def billing_days_left
    (self.next_billing_date.to_datetime - Date.today).to_i
  end
  
  def self.update_numbers
    Party.all.each do |party|
      puts "UPDATING NUMBERS FOR #{party.hf_party_id}"
      if !party.next_billing_date
        party.set_billing_info
      else 
        party.update_next_billing_date 
      end
      party.get_mtd_leads
      party.get_party_pageviews
      party.update_listing_count
    end
  end

  def self.set_billing_info(force = false)
    parties =  Party.where("next_billing_date IS NULL")
    parties = Party.all if force
    parties.each do |party|
      party.set_billing_info
    end
  end

  def set_billing_info
    #set next billing date, zip code plan code, and zip code quantity
    rec_account = self.recurly_account
    if rec_account && rec_account.subscriptions
      self.next_billing_date = rec_account.subscriptions.first.current_period_ends_at
      self.subscriber_since = rec_account.subscriptions.first.activated_at
      self.recurly_addon_array = rec_account.subscriptions.first.subscription_add_ons
      self.save!
    elsif rec_account
      puts "RECURLY ACCOUNT, NO SUBSCRIPTIONS"
    else
      puts "NO RECURLY ACCOUNT"
    end
  end

  def self.update_next_billing_dates
    Party.all.each do |party|
      party.update_next_billing_date
    end
  end
  
  def update_next_billing_date
    if !self.next_billing_date || self.next_billing_date < Time.now
      rec_account = self.recurly_account
      if rec_account && rec_account.subscriptions && rec_account.subscriptions.count > 0
        self.next_billing_date = rec_account.subscriptions.first.current_period_ends_at
        self.save!
      end
    end
  end
    
  def self.get_mtd_leads
    Party.all.each do |party|
      party.get_mtd_leads
    end
    return 1
  end
  
  def self.get_party_pageviews
    Party.all.each do |party|
      party.get_party_pageviews
    end
  end
  
  def self.get_spw_stats
    ga = Gattica.new({ 
        :email => 'dbreaker@homefinder.com', 
        :password => 'Tcmi12mnidb'
    })    
    ga.profile_id = 44468872 #agent party pages
    #set start date to 5/22 or after
    start_date = Date.parse("2012-01-01").strftime("%Y-%m-%d")
    end_date = Time.now.strftime("%Y-%m-%d")
    puts "start: #{start_date} - end: #{end_date}"
    data = ga.get({ 
      :start_date => start_date,
      :end_date => end_date,
      :dimensions => ['hostname','isMobile'],
      :metrics => ['visits']
    })
#    puts data.to_h['points']
    puts data.to_csv(:short)
  end
  
  def get_party_pageviews
    profile_id = 60102324 #agent party pages
    #set start date to 5/22 or after
    if self.next_billing_date
      start_date = (self.next_billing_date - 1.month).strftime("%Y-%m-%d")
    else
      start_date = Time.now.at_beginning_of_month.strftime("%Y-%m-%d")
    end
    end_date = Time.now.strftime("%Y-%m-%d")

    # Credentials can be obtained @ https://code.google.com/apis/console/ under "API Access"
    client_id = '1096301339654.apps.googleusercontent.com'
    client_secret = 'u77nI4qbHg_4-brnX-QBH6FR'
    # This can be obtained @ https://code.google.com/oauthplayground
    refresh_token = '1/fql3tgW3w7uMtuVI-sC_Lr2ufT4wxNIY3JEvSnQAWAo'

    client = Google::APIClient.new
    client.authorization.client_id = client_id
    client.authorization.client_secret = client_secret
    client.authorization.scope = 'https://www.googleapis.com/auth/analytics'

    client.authorization.refresh_token = refresh_token
    client.authorization.fetch_access_token!

    api = client.discovered_api('analytics', 'v3')

    response = client.execute(
        :api_method => api.data.ga.get,
        :parameters => {'start-date' => start_date,
                        'end-date' => end_date,
                        :ids => "ga:#{profile_id}",
                        :metrics => "ga:pageviews",
                        :dimensions => 'ga:pagePath',
                        :filters => "ga:pagePath=~#{self.hf_party_id}d"}
    )
    response_json = JSON.parse(response.data.to_json)

    puts "Response:"
    puts response_json

    puts "\n============"
    puts "Total visits:"
    puts response_json['totalsForAllResults']['ga:pageviews'] rescue "N/A"

    if response_json['totalsForAllResults']['ga:pageviews']
      self.mtd_pageviews = response_json['totalsForAllResults']['ga:pageviews']
    else
      self.mtd_pageviews = 0
    end
    self.save!

#    if response_json['rows']
#      puts "\n============"
#      puts "Individual rows:"
#      response_json['rows'].each do |row|
#        puts "URL: #{row[0]} = #{row[1]}"
#      end
#    end
  end
  
  def update_listing_count
    url = "http://api.homefinder.com/listingServices/search?partyId=#{self.hf_party_id}"
    puts url
    results =""
    open(url) do |f|
      results = f.read
    end
    listings_array = []
    result_hash = JSON.parser.new(results,{}).parse
    if result_hash["status"]["code"].to_i == 200 && result_hash["data"]["meta"]["totalMatched"]
      puts y result_hash["data"]["meta"]
      puts "FOUND #{result_hash["data"]["meta"]["totalMatched"]} LISTINGS FOR PARTY ID: #{self.hf_party_id}"
      self.number_of_listings = result_hash["data"]["meta"]["totalMatched"]
      self.save!
      listings_array = result_hash["data"]["listings"] if (self.number_of_listings  && self.number_of_listings > 0)
    end
    listings_array
  end
  
  def set_products
    return nil if !self.recurly_addon_array || self.recurly_addon_array.size == 0
    puts y self.recurly_addon_array
    self.recurly_addon_array
    
  end
  
  def self.get_adwords_performance
    adwords = AdwordsApi::Api.new({
      :authentication => {
          :method => 'ClientLogin',
          :developer_token => 'DEVELOPER_TOKEN',
          :user_agent => 'Ruby Sample',
          :password => 'PASSWORD',
          :email => 'user@domain.com',
          :client_customer_id => '012-345-6789'
      },
      :service => {
        :environment => 'PRODUCTION'
      }
    })
  end
  
  def self.get_dfp_ad_performance
    dfp = DfpApi::Api.new({
       :authentication => {
           :method => 'ClientLogin',
           :application_name => 'Traffic Cop',
           :email => 'dbreaker@homefinder.com',
           :password => 'PASSWORD',
           :network_code => 1039964
       },
       :service => {
         :environment => "PRODUCTION"
       }
     })
=begin
    dfp = DfpApi::Api.new({
       :authentication => {
           :method => 'OAuth2',
           :application_name => 'Traffic Cop',
           :oauth2_client_id => '1096301339654.apps.googleusercontent.com',
           :oauth2_client_secret => 'u77nI4qbHg_4-brnX-QBH6FR',
           :network_code => 1039964
       },
       :service => {
         :environment => "PRODUCTION"
       }
     })
=end     
    api_version = :v201208
    # Get the CreativeService.
    forecast_service = dfp.service(:ForecastService, api_version)

    # Set the line item to get a forecast for.
    begin
      # Get forecast for line item.
      # Set the placement that the prospective line item will target.
      targeted_placement_ids = [621964] #details page

      # Create targeting.
      targeting = {
          :inventory_targeting =>
              {:targeted_placement_ids => targeted_placement_ids},
          :custom_targeting =>
              {:key => 'zipCode', }
      }

      # Create the creative placeholder.
      creative_placeholder = {
          :size => {:width => 160, :height => 600, :is_aspect_ratio => false}
#          :size => {:width => 240, :height => 470, :is_aspect_ratio => false}
      }

      start_date = Date.today + 1.day
      end_date = Date.today + 1.month
      # Create prospective line item.
      line_item = {
        :line_item_type => 'SPONSORSHIP',
        :targeting => targeting,
        # Set the size of creatives that can be associated with this line item.
        :creative_placeholders => [creative_placeholder],
        # Set the line item's time to be now until the projected end date time.
        :start_date_time => Time.utc(start_date.year, start_date.month, start_date.day),
        :end_date_time => Time.utc(end_date.year, end_date.month, end_date.day),
        # Set the line item to use 50% of the impressions.
        :unit_type => 'IMPRESSIONS',
        :units_bought => 100,
        # Set the cost type to match the unit type.
        :cost_type => 'CPM'
      }

      # Get forecast for the line item.
      forecast = forecast_service.get_forecast(line_item)

      if forecast
        puts y forecast
        # Display results.
        matched = forecast[:matched_units]
        available_percent = forecast[:available_units] * 100.0 / matched
        unit_type = forecast[:unit_type].to_s.downcase
        puts "%.2f %s matched." % [matched, unit_type]
        puts "%.2f%% %s available." % [available_percent, unit_type]
        if forecast[:possible_units]
          possible_percent = forecast[:possible_units] * 100.0 / matched
          puts "%.2f%% %s possible." % [possible_percent, unit_type]
        end
      end

    rescue AdsCommon::Errors::HttpError => e
      puts "HTTP Error: %s" % e

    # API errors.
    rescue DfpApi::Errors::ApiException => e
      puts "Message: %s" % e.message
      puts 'Errors:'
      e.errors.each_with_index do |error, index|
        puts "\tError [%d]:" % (index + 1)
        error.each do |field, value|
          puts "\t\t%s: %s" % [field, value]
        end
      end
    end
  end
=begin
  
  def get_adwords_performance
    APPLICATION_TOKEN = 'IGNORED'
    DEVELOPER_TOKEN = '3_Ne5yUOnOrkPEwf_Aw6tg'
    PASSWORD = 'pickles4me'
    EMAIL = 'doug@pickleofthemonth.com'
    CLIENT_EMAIL = 'doug@pickleofthemonth.com'
    API_VERSION = :v201009
    
    adwords = AdwordsApi::Api.new({
      :authentication => {
          :method => 'ClientLogin',
          :developer_token => DEVELOPER_TOKEN,
          :user_agent => 'Ruby Sample',
          :password => PASSWORD,
          :email => EMAIL#,
#          :client_customer_id => '012-345-6789'
      },
      :service => {
        :environment => 'PRODUCTION'
      }
    })
    campaign_srv = adwords.service(:CampaignService, API_VERSION)
    campaigns = campaign_srv.get({:fields => ['Id', 'Name', 'Status']})
    puts y campaigns
  end
  
  def self.get_share_report
    #start with all recurly accounts
  end
=end


    def self.get_parties_from_recurly
        report_array = []
        report_array << ["STATUS", "ACTIVATED", "CANCELED", "DURATION DAYS", "FIRST NAME", "LAST NAME", "ONE TIMES PURCHASED", "RECURRING PURCHASED", "EMAIL", "DIRECT/AFFILIATE", "SPWS", "SPWS_WITH_CLIENT_EMAILS", "FB SHARES", "TWEETS"]
        Recurly::Account.find_each do |account|
          #first name, last name, address, city, state, zip , month of purchase, day of purchase, year of purchase, one time number of spws purchased, recurring spws purchased, e-mail address, direct or affiliate
          has_billing_info = ("Yes" if account.billing_info) || "No"
          puts "INSPECTING #{account.state} has billing info? #{has_billing_info}"
          if account.subscriptions.first
            #account.state == "active" && account.subscriptions.first.state == "active" 
            #get HF spw info and affiliate
            hf_url = "https://#{HOMEFINDER_API_ENVIRONMENT}/singlePropertyWebsiteServices/getAdvertisers?id=#{account.account_code}&returnAuthorizations=true"
            puts hf_url
            hf_authorization = ""
            open(hf_url) do |f|
              hf_authorization = f.read
            end
            one_time_sites = 0
            recurring_sites = 0
            affiliate = ""
            hf_authorization = JSON.parser.new(hf_authorization,{}).parse
            if hf_authorization["status"]["code"].to_i == 200
              affiliate = hf_authorization["data"]["advertisers"].first["affiliate"]
              one_times = hf_authorization["data"]["advertisers"].first["oneTimePropertyWebsiteAuthorization"]
              if one_times
          			one_time_sites = one_times["numberAuthorized"]
              end
              recurring = hf_authorization["data"]["advertisers"].first["recurringPropertyWebsiteAuthorization"]
              if recurring
                recurring_sites = recurring["numberAuthorized"] || 0
              end
            end
            spw_hash =  User.get_party_spws(account.account_code)
            puts "ADDING ACCOUNT #{account.first_name} #{account.last_name}"
            row_array = []
            row_array << account.subscriptions.first.state #status
            row_array << account.subscriptions.first.activated_at #subscription activated at
            row_array << account.subscriptions.first.canceled_at #subscription canceled at
            row_array << (account.subscriptions.first.canceled_at - account.subscriptions.first.activated_at if account.subscriptions.first.canceled_at) || 0 #subscription canceled at
            row_array << account.first_name
            row_array << account.last_name
            row_array << one_time_sites
            row_array << recurring_sites
            row_array << account.email
            row_array << affiliate
            row_array << spw_hash[:spw_count]
            row_array << spw_hash[:seller_email_count]
            row_array << spw_hash[:spws_fb_shared]
            row_array << spw_hash[:spws_tweeted]
            report_array << row_array
            puts "ADDED ROW"
            puts row_array.join(", ")
          end
        end
        report_array
    end

    def self.get_party_spws(party_id)
      url =  "https://api.homefinder.com/singlePropertyWebsiteServices/getPropertyWebsites?_debug=true&advertiserId=#{party_id}&resultSize=50"
      results = ""
      puts url
      open(url) do |f|
        results = f.read
      end
      party_results_hash = JSON.parser.new(results,{}).parse
      return_hash = {}
      if party_results_hash["status"]["code"].to_i == 200 && party_results_hash["data"]["propertyWebsites"]
        spws = party_results_hash["data"]["propertyWebsites"]
        spws_fb_shared  = 0
        spws_tweeted = 0
        seller_email_count = 0
        #roll through spws
        spws.each do |spw|
          spws_fb_shared += 1 if spw["facebookLikes"] > 0
          spws_tweeted += 1 if spw["twitterTweets"] > 0
          seller_email_count += 1 if (spw["clientEmail"]  && !spw["clientEmail"].blank?)
        end
        return_hash[:spws_fb_shared] = spws_fb_shared
        return_hash[:spws_tweeted] = spws_tweeted
        return_hash[:seller_email_count] = seller_email_count
  #      return_hash[:spws] = spws
        return_hash[:spw_count] = party_results_hash["data"]["meta"]["totalMatched"]
      end  
      return_hash
    end
  
  def self.create_livechat_operator
    username = 'dbreaker@gmail.com'
    password = 'a21492f26f5b7f17941ae072bdeaa6d4'
    base_url = 'https://api.livechatinc.com'

    resp = href = "";
    begin
      http = Net::HTTP.new("api.livechatinc.com", 443)
      http.use_ssl = true
      http.start do |http|
#        req = Net::HTTP::Get.new("/operators", {"User-Agent" =>
#            "juretta.com RubyLicious 0.2"})
        req = Net::HTTP::Post.new("/operators")
        req.set_form_data('login' => 'scullins@homefinder.com', 
                          'password' => 'fatwillys',
                          'name' => "Shannon Cullins",
                          "title" => "Real Estate Agent",
                          "display_name" => "Shannon Cullins",
                          "permission" => "normal"
                          )
        req.basic_auth(username, password)
        response = http.request(req)
        resp = response.body
      end
      puts resp
    rescue SocketError
      raise "Host " + host + " error"
    end
    
#    Livechat.config do |c|
#      c.base_uri 'https://api.livechatinc.com'
#      c.username 'dbreaker@gmail.com'
#      c.password '088b081e1d40dfba78ef4d47ef40b229'
#    end
#    status = Livechat::Status.new
#    pp status.show
  end
  
  def search_yelp
    #get a zip from listings
    listings = self.update_listing_count
    puts "found #{listings.size} listings"
    if listings.size > 0
      zip = listings.first["address"]["zip"]
      lat = listings.first["address"]["latitude"]
      lng = listings.first["address"]["longitude"]
      #now get yelp results
      consumer_key = 'Z6N8EbpNeQ11Ma7oyQI27w'
      consumer_secret = 'j4f1HJtCo0W7C-I43as5qKyZYBU'
      token = '1SMDO6OF1qjouzsmAy6X_84bdO2q5_O6'
      token_secret = 'V2zedQoPnKKKG1WTvp39ex3VKcI'

      api_host = 'api.yelp.com'

      consumer = OAuth::Consumer.new(consumer_key, consumer_secret, {:site => "http://#{api_host}"})
      access_token = OAuth::AccessToken.new(consumer, token, token_secret)
      
      search_name = self.name
      zip = "chicago, il"
      search_name = "mike mccallum"
      #term=#{CGI::escape(search_name)}&
      path = "/v2/search?location=#{CGI::escape(zip)}&category_filter=realestateagents&radius_filter=25"
      url = "http://#{api_host}#{path}"
      puts url

      puts access_token.get(path).body
    end
  end
  
  private
  # Misc util to get the verification code from the console.
  def self.get_verification_code(url)
    puts "Hit Auth error, please navigate to URL:\n\t%s" % url
    print 'Log in and type the verification code: '
    verification_code = gets.chomp
    return verification_code
  end
end
