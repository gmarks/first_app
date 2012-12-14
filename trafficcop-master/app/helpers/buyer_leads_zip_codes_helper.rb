require 'dfp_api'

module BuyerLeadsZipCodesHelper

  PAGE_SIZE = 500

  def self.get_geo_code_names(zip_code)
    url = "http://api.geonames.org/postalCodeSearchJSON?postalcode=#{zip_code}&maxRows=100&username=homefinder&country=US"
    res =  Typhoeus::Request.get(url, followlocation: true)
    results = JSON.parse(res.body)

    if (results) && (results["postalCodes"].size == 0 )
      return "Invalid ZipCode"
    else
      city_name = results["postalCodes"].first["placeName"]
      state_name = results["postalCodes"].first["adminName1"]
      state_short_name = results["postalCodes"].first["adminCode1"]
    end
    result = {
      :city_name => city_name,
      :state_name => state_name,
      :state_short_name => state_short_name
    }
  end

  def self.get_dfp
    access_token = GoogleAuthToken.first.get_access_token
    dfp = DfpApi::Api.new({
                            :authentication => {
                              :method => 'OAuth2',
                              :application_name => 'Traffic Cop',
                              :oauth2_client_id => Trafficcop::Application::CLIENT_ID,
                              :oauth2_client_secret => Trafficcop::Application::CLIENT_SECRET,
                              :oauth2_token => {"access_token"=> access_token, "token_type"=>"Bearer", "refresh_token"=>Trafficcop::Application::GOOGLE_REFRESH_TOKEN},
                              :network_code => 1039964
                            },
                            :service => {
                              :environment => 'PRODUCTION'
                            },
                            :library => {
                              :log_level => 'DEBUG'
                            }
    })

    dfp
  end

  def self.get_zip_code_value_id(dfp,zip_code_value)

    custom_targeting_service = dfp.service(:CustomTargetingService, Trafficcop::Application::API_VERSION)
    zip_code_id = 46684

    offset = 0
    page = {}

    statement_text = "WHERE customTargetingKeyId = :key_id LIMIT %d" % PAGE_SIZE
    statement = {
      :values => [
        {:key => 'key_id',
         :value => {:value => zip_code_id,
                    :xsi_type => 'NumberValue'}}
      ]
    }

    begin

      statement[:query] = statement_text + " OFFSET %d" % offset

      page = custom_targeting_service.get_custom_targeting_values_by_statement(
      statement)

      if page[:results]
        offset += PAGE_SIZE

        start_index = page[:start_index]

        page[:results].each_with_index do |custom_targeting_value, index|
          if custom_targeting_value[:name] == zip_code_value
            return custom_targeting_value[:id]
          end

        end
      end
    end while offset < page[:total_result_set_size]                      
    
    #Create a custom value and return its ID if the previous wasnt found.
    create_custom_targeting_value(dfp,zip_code_value)    
  end

  def self.empty_results
    result = {
      :available_units => 0,
      :unit_type => 0,
      :available_percent => 0,
      :delivered_units => 0,
      :possible_units => 0,
      :reserved_units => 0,
      :city => "",
      :state => "",
      :page_views => 0 ,
      :page_visits => 0,
    }
    result
  end
  
  def self.create_custom_targeting_value(dfp,zip_code_value)  
     
    zip_code_custom_targeting_id = 46684 
    custom_targeting_service = dfp.service(:CustomTargetingService, Trafficcop::Application::API_VERSION)
    
    # Create another custom targeting value for the same key.
    zipcode_value = {:custom_targeting_key_id => zip_code_custom_targeting_id,
        :display_name => '', :name => zip_code_value, :match_type => 'EXACT'}
   
   # Create the custom targeting values on the server.
   return_values = custom_targeting_service.create_custom_targeting_values([zipcode_value])
   return_values[0][:id]   
  end
  
  def self.dfp_estimation(zip_code) 
    @buyer_leads_zip_code = BuyerLeadsZipCode.new
    @buyer_leads_zip_code.zip_code = zip_code 
    @buyer_leads_zip_code.get_zip_code_impressions_for_next_month
  end

end
