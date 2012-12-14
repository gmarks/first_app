class LineItem < ActiveRecord::Base
  include  BuyerLeadsZipCodesHelper

  validates :inventory_sizes, :presence => true
  validates :custom_criteria, :presence => true
  validates :units_bought, :presence => true
  validates :end_time,
    :date => {:after => :start_time, :message => 'The end date must be after the start date'},
    :on => :create


    def self.get_line_item_details(dfp_line_item_id)
      dfp = BuyerLeadsZipCodesHelper.get_dfp
      line_item_service =    dfp.service(:LineItemService,Trafficcop::Application::API_VERSION)
      line_item_id = dfp_line_item_id.to_i

      # Get the line item.
      line_item = line_item_service.get_line_item(line_item_id)

      if line_item
        puts "Line item with ID: %d, name: %s and order id: %d was found." %
            [line_item[:id], line_item[:name], line_item[:order_id]]
      else
        puts 'No line item found for this ID.'
      end
      line_item 
    end
    
  def self.create_line_item_on_dfp(params,valid_line_item)



    dfp = BuyerLeadsZipCodesHelper.get_dfp
    line_item_service =    dfp.service(:LineItemService,Trafficcop::Application::API_VERSION)

    order_id = Trafficcop::Application::GOOGLE_DFP_ORDER_ID.to_i
    targeted_placement_ids = [3593404]

    inventory_targeting = {:targeted_placement_ids => targeted_placement_ids}

    zip_codes =  params[:line_item][:custom_criteria].split(",")
    zip_codes_ids = []
    zip_codes.each do |zip_code|
      zip_codes_ids << BuyerLeadsZipCodesHelper.get_zip_code_value_id(dfp,zip_code)
    end
    custom_criteria = [
      {:xsi_type => 'CustomCriteria',
       :key_id => 46684,
       :value_ids => zip_codes_ids,
       :operator => 'IS'
       }
    ]

    sub_custom_criteria_set = {
      :xsi_type => 'CustomCriteriaSet',
      :logical_operator => 'AND',
      :children => [custom_criteria[0]]
    }

    targeting = {:inventory_targeting => inventory_targeting,
                 :custom_targeting => sub_custom_criteria_set
                 }

    line_item =
      {:name => "Buyer Leads for Zip Codes (#{zip_codes.join(",")})",
       :order_id => order_id,
       :targeting => targeting,
       :line_item_type => 'SPONSORSHIP',
       :allow_overbook => false}
      line_item[:creative_rotation_type] = 'EVEN'

    sizes = params[:line_item][:inventory_sizes].split(",")
    sizes.delete(" ")
    creative_placeholders = []
    sizes.each do |size|
      size = size[/\(.*?\)/].gsub("(","").gsub(")","").split("X")
      placeholder = {
        :size =>
        {
          :width => size[0].to_i,
          :height => size[1].to_i,
          :is_aspect_ratio => false
        }
      }
      creative_placeholders << placeholder
    end

    start_time = DateTime.parse(params[:start_time])
    end_time = DateTime.parse(params[:end_time])

    line_item[:creative_placeholders] = creative_placeholders

    line_item[:start_date_time] = start_time.to_time
    line_item[:end_date_time] = end_time.to_time
    line_item[:status] = "PAUSED"

    line_item[:cost_type] = 'CPM'
    line_item[:cost_per_unit] = {
      :currency_code => 'USD',
      :micro_amount => 1
    }

    line_item[:units_bought] = params[:line_item][:units_bought].to_i
    line_item[:unit_type] = 'IMPRESSIONS'

    return_line_items = line_item_service.create_line_items([line_item]) 
    pause_line_item(line_item_service,return_line_items[0][:id],order_id)
    line_item[:name]
  end

  def self.pause_line_item(line_item_service,line_item_id,order_id)

    statement_text = 'WHERE orderID = :order_id'
    statement = {
      :values => [
        {:key => 'order_id',
         :value => {:value => order_id, :xsi_type => 'NumberValue'}}

      ]
    }
    statement[:query] = statement_text + " AND id IN (%s)" % line_item_id
    result = line_item_service.perform_line_item_action(
      {:xsi_type => 'PauseLineItems'}, statement)

      # Display results.
      if result and result[:num_changes] > 0
        puts "Number of line items activated: %d" % result[:num_changes]
      else
        puts 'No line items were activated.'
      end

  end

end
