require 'adwords_api'

module AdwordsHelper

  API_VERSION = :v201209

  def self.get_adwords_client
    access_token = GoogleAuthToken.first.get_access_token
    AdwordsApi::Api.new({
                          :authentication => {
                            :method => 'OAuth2',
                            :application_name => 'Traffic Cop',
                            :oauth2_client_id => Trafficcop::Application::CLIENT_ID,
                            :oauth2_client_secret => Trafficcop::Application::CLIENT_SECRET,
                            :developer_token => '3_Ne5yUOnOrkPEwf_Aw6tg',
                            :oauth2_token => {"access_token"=> access_token, "token_type"=>"Bearer", "refresh_token"=>Trafficcop::Application::GOOGLE_REFRESH_TOKEN}#,
                            #   :network_code => 1039964
                          },
                          :service => {
                            :environment => 'PRODUCTION'
                          },
                          :library => {
                            :log_level => 'DEBUG'
                          }
    })
  end

  def self.estimate_by_zip_code(zip_code)

    adword_client = get_adwords_client
    traffic_estimator_srv = adword_client.service(:TrafficEstimatorService, API_VERSION)

    # Create keywords. Up to 2000 keywords can be passed in a single request.
    keywords = [
      # The 'xsi_type' field allows you to specify the xsi:type of the object
      # being created. It's only necessary when you must provide an explicit
      # type that the client library can't infer.
      {:xsi_type => 'Keyword', :text => "#{zip_code}", :match_type => 'BROAD'}
     
    ]

    # Create a keyword estimate request for each keyword.
    keyword_requests = keywords.map {|keyword| {:keyword => keyword}}

    # Create ad group estimate requests.
    ad_group_request = {
      :keyword_estimate_requests => keyword_requests,
      :max_cpc => {
        :micro_amount => 1000000
      }
    }

    # Create campaign estimate requests.
    campaign_request = {
      :ad_group_estimate_requests => [ad_group_request],
      # Set targeting criteria. Only locations and languages are supported.
      :criteria => [
        {:xsi_type => 'Location', :id => 2840}, # United States
        {:xsi_type => 'Language', :id => 1000}  # English
      ]
    }

    # Create selector and retrieve reults.
    selector = {:campaign_estimate_requests => [campaign_request]}
    response = traffic_estimator_srv.get(selector)
    adword_estimation_result = {}
    if response and response[:campaign_estimates]
      campaign_estimates = response[:campaign_estimates]
      keyword_estimates =
        campaign_estimates.first[:ad_group_estimates].first[:keyword_estimates]
      keyword_estimates.each_with_index do |estimate, index|
        keyword = keyword_requests[index][:keyword]

        # Find the mean of the min and max values.
        mean_avg_cpc = (estimate[:min][:average_cpc][:micro_amount] +
                        estimate[:max][:average_cpc][:micro_amount]) / 2
        mean_avg_position = (estimate[:min][:average_position] +
                             estimate[:max][:average_position]) / 2
        mean_clicks = (estimate[:min][:clicks_per_day] +
                       estimate[:max][:clicks_per_day]) / 2
        mean_total_cost = (estimate[:min][:total_cost][:micro_amount] +
                           estimate[:max][:total_cost][:micro_amount]) / 2
       
        adword_estimation_result[:mean_avg_cpc] = mean_avg_cpc
        adword_estimation_result[:mean_avg_position] = mean_avg_position
        adword_estimation_result[:mean_clicks] = mean_clicks
        adword_estimation_result[:mean_total_cost] = mean_total_cost
        # puts "Results for the keyword with text '%s' and match type %s:" %
        #        [keyword[:text], keyword[:match_type]]
        #        puts "\tEstimated average CPC: %d" % mean_avg_cpc
        #        puts "\tEstimated ad position: %.2f" % mean_avg_position
        #        puts "\tEstimated daily clicks: %d" % mean_clicks
        #        puts "\tEstimated daily cost: %d" % mean_total_cost 
      end
    else
      puts 'No traffic estimates were returned.'
    end
     adword_estimation_result
  end

end
