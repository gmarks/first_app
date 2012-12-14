class BuyerLeadsZipCode < ActiveRecord::Base

  belongs_to :party
  belongs_to :zip_code

  def get_zip_code_impressions_for_next_month
    BuyerLeadsZipCode.get_zip_code_impressions_for_next_month(self.zip_code.zip_code)
  end

  def self.get_zip_code_impressions_for_next_month(zip_code = "11772")

    # Zip Code Validation
    return "Invalid ZipCode" if zip_code==""
    geo_code_names = BuyerLeadsZipCodesHelper.get_geo_code_names(zip_code)
    return geo_code_names if geo_code_names.class == String

#    analytics_results = GoogleAnalyticsHelper.page_views_by_city_and_state(geo_code_names[:city_name],geo_code_names[:state_short_name])


    dfp = BuyerLeadsZipCodesHelper.get_dfp

    forecast_service = dfp.service(:ForecastService,Trafficcop::Application::API_VERSION)

    begin
      targeted_placement_ids = [621964]


      # Create custom criteria.
      custom_criteria = [
        {:xsi_type => 'CustomCriteria',
         :key_id => 46684,
         :value_ids => [BuyerLeadsZipCodesHelper.get_zip_code_value_id(dfp,zip_code)],
         :operator => 'IS'},
               {:xsi_type => 'CustomCriteria',
                :key_id => 259564,             # This is the enhancedDP custom field
                :value_ids => [43259590684],   # This is the yes value
                :operator => 'IS_NOT'}
      ]

      sub_custom_criteria_set = {
        :xsi_type => 'CustomCriteriaSet',
        :logical_operator => 'AND',
        :children => [custom_criteria[0], custom_criteria[1]]
      }

      targeting = {
        :inventory_targeting =>
        {:targeted_placement_ids => targeted_placement_ids},
        :custom_targeting => sub_custom_criteria_set
      }

      creative_placeholder = {
        :size => {:width => 160, :height => 600, :is_aspect_ratio => false}
      }

      start_date = Date.today + 1.day
      end_date = Date.today + 1.month
      # Create prospective line item.
      line_item = {
        :line_item_type => 'SPONSORSHIP',
        :targeting => targeting,
        :creative_placeholders => [creative_placeholder],
        :start_date_time => Time.utc(start_date.year, start_date.month, start_date.day),
        :end_date_time => Time.utc(end_date.year, end_date.month, end_date.day),
        :unit_type => 'IMPRESSIONS',
        :units_bought => 100,
        :cost_type => 'CPM',
      }

      # Get forecast for the line item.
      forecast = forecast_service.get_forecast(line_item)
      if forecast
        matched = forecast[:matched_units]
        result = {
          :available_units => matched,
          :unit_type => forecast[:unit_type].to_s.downcase,
          :available_percent => forecast[:available_units] * 100.0 / matched,
          :delivered_units => forecast[:delivered_units],
          :possible_units => forecast[:possible_units],
          :reserved_units => forecast[:reserved_units],
          :start_date_time => Time.utc(start_date.year, start_date.month, start_date.day),
          :end_date_time => Time.utc(end_date.year, end_date.month, end_date.day),
          :city => geo_code_names[:city_name],
          :state => geo_code_names[:state_name]#,
#          :page_views => analytics_results[:page_views] ,
#          :page_visits => analytics_results[:page_visitis]
        }
        return result
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
      BuyerLeadsZipCodesHelper.empty_results
    end


  end

end
