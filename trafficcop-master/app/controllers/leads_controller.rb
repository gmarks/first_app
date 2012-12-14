require 'open-uri'
require 'json'

class LeadsController < ApplicationController
  # GET /leads
  # GET /leads.json
  def index
    @leads = Lead.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @leads }
    end
  end

  def adcreative
  end

  # GET /leads/1
  # GET /leads/1.json
  def show
    @lead = Lead.find(params[:id])
    @partyid = @lead.agent_id.to_s
    @partyservicesurl = "http://services.homefinder.com/partyServices/details?id=#{@partyid}&apikey=#{HF_API_KEY}"
    @partyservicesresponse = JSON.parse(open(@partyservicesurl).read)
    logger.debug "#{@partyservicesresponse}" 
    @agentpicurl = @partyservicesresponse['data']['parties'][@partyid]['largeLogoUrl']
    @agentname = @partyservicesresponse['data']['parties'][@partyid]['name']
    @brokername = @partyservicesresponse['data']['parties'][@partyid]['companyName']
    @listingsurl = @partyservicesresponse['data']['parties'][@partyid]['listingsUrl']
    
    @click_url = session[:click_url]

    if @click_url != nil
      @listingsurl = @click_url + URI.escape(@listingsurl)
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lead }
    end
  end


  # GET /leads/new
  # GET /leads/new.json
  def new
    @lead = Lead.new
    session.delete(:click_url)
    @partyid = params[:partyid]
    @zipcode = params[:zipcode]
    @test_ind = params[:test_ind]
    @click_url = params[:click_url]
    @listingid = params[:listingid]
    logger.debug "partyid parameter in url: #{params[:partyid]}"
    logger.debug "partyid variable set: #{@partyid}"
    logger.debug "listingid parameter in url: #{params[:listingid]}"
    logger.debug "listingid variable set: #{@listingid}"
    @leaderboard = params[:leaderboard]
    @detailstfn = params[:detailstfn]
    # logger.debug "party_id: #{@partyid}"    
    # logger.debug "test_ind: #{@test_ind}"    
    # logger.debug "click_url: #{@click_url}"    
    @partyservicesurl = "http://services.homefinder.com/partyServices/details?id=#{@partyid}&apikey=#{HF_API_KEY}"
    logger.debug "partyservicesurl: #{@partyservicesurl}"    
    @partyservicesresponse = JSON.parse(open(@partyservicesurl).read)
    logger.debug "#{@partyservicesresponse}"
    # logger.debug "partyid: #{@partyid}"    
    # logger.debug "full response: #{@partyservicesresponse}"    
    # logger.debug "data: #{@partyservicesresponse['data']}"    
    # logger.debug "parties: #{@partyservicesresponse['data']['parties']}"    
    # logger.debug "partyid: #{@partyservicesresponse['data']['parties'][@partyid]}"
    # logger.debug "largelogourl: #{@partyservicesresponse['data']['parties'][@partyid]['largeLogoUrl']}"    
    @agentpicurl = @partyservicesresponse['data']['parties'][@partyid]['largeLogoUrl']
    @agentname = @partyservicesresponse['data']['parties'][@partyid]['name']
    @parentpartyid = @partyservicesresponse['data']['parties'][@partyid]['parentPartyId']
    @listingsurl = @partyservicesresponse['data']['parties'][@partyid]['listingsUrl']
    # logger.debug "listingsurl: #{@listingsurl}"
      if @click_url != nil
        @listingsurl = @click_url + URI.escape(@listingsurl)
        session[:click_url] = @click_url
      end
      if @listingid != nil && @listingid !=""
        @listingservicesurl = "http://services.homefinder.com/listingServices/details?id=#{@listingid}&apikey=#{HF_API_KEY}"
        logger.debug "listingservicesurl: #{@listingservicesurl}"
        @listingservicesresponse = JSON.parse(open(@listingservicesurl).read)
        @listingurl = @listingservicesresponse['data']['listing']['url']
        logger.debug "listingurl: #{@listingurl}"
        @listingaddress = @listingservicesresponse['data']['listing']['address']['line1']
        @listingaddress2 = @listingservicesresponse['data']['listing']['address']['line2']
        @listingcity = @listingservicesresponse['data']['listing']['address']['city']        
        logger.debug "listingaddress: #{@listingaddress}"
        logger.debug "listingaddress2: #{@listingaddress2}"
        logger.debug "listingcity: #{@listingcity}"
      end

    @parentpartyservicesurl = "http://services.homefinder.com/partyServices/details?id=#{@parentpartyid}&apikey=#{HF_API_KEY}"
    logger.debug "parentpartyservicesurl: #{@parentpartyservicesurl}"    
    # @parentpartyservicesresponse = JSON.parse(open(@parentpartyservicesurl).read)
    # logger.debug "parentpartyid: #{@parentpartyid}"    
    # @brokername = @parentpartyservicesresponse['data']['parties'][@parentpartyid]['name']
    
    if @partyservicesresponse['data']['parties'][@partyid]['tollFree']
      @phone = @partyservicesresponse['data']['parties'][@partyid]['tollFree']
    else
      @phone = 'AddThePhone'
    end
    
    if @phone
        @phone1 = @phone[0,3]
        @phone2 = @phone[3,3]
        @phone3 = @phone[6,4]
    end
    
    logger.debug "#{@partyservicesresponse}"    
    logger.debug "phone: #{@phone}"

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lead }
    end
  end

  # GET /leads/1/edit
  def edit
    @lead = Lead.find(params[:id])
  end

  # POST /leads
  # POST /leads.json
  def create
    @lead = Lead.new(params[:lead])

    @partyid = @lead.agent_id.to_s
    @partyservicesurl = "http://services.homefinder.com/partyServices/details?id=#{@partyid}&apikey=#{HF_API_KEY}"
    @partyservicesresponse = JSON.parse(open(@partyservicesurl).read)   
    @agentpicurl = @partyservicesresponse['data']['parties'][@partyid]['largeLogoUrl']
    @agentname = @partyservicesresponse['data']['parties'][@partyid]['name']
    @brokername = @partyservicesresponse['data']['parties'][@partyid]['companyName']
    @listingsurl = @partyservicesresponse['data']['parties'][@partyid]['listingsUrl']

    if @partyservicesresponse['data']['parties'][@partyid]['tollFree']
      @phone = @partyservicesresponse['data']['parties'][@partyid]['tollFree']
    else
      @phone = 'AddThePhone'
    end
    
    if @phone
        @phone1 = @phone[0,3]
        @phone2 = @phone[3,3]
        @phone3 = @phone[6,4]
    end
    
    logger.debug "#{@partyservicesresponse}"    
    logger.debug "phone: #{@phone}"

    @listingid = @lead.listing_id
    logger.debug "@listingid: #{@listingid}"
    if @listingid != nil && @listingid != ""
      @listingservicesurl = "http://services.homefinder.com/listingServices/details?id=#{@listingid}&apikey=#{HF_API_KEY}"
      logger.debug "listingservicesurl: #{@listingservicesurl}"
      @listingservicesresponse = JSON.parse(open(@listingservicesurl).read)
      @listingurl = @listingservicesresponse['data']['listing']['url']
      logger.debug "listingurl: #{@listingurl}"
      @listingaddress = @listingservicesresponse['data']['listing']['address']['line1']
      @listingaddress2 = @listingservicesresponse['data']['listing']['address']['line2']
        if @listingaddress2 != nil
          @listingaddress = @listingaddress + ", " + @listingaddress2
        end
      @listingcity = @listingservicesresponse['data']['listing']['address']['city']        
      logger.debug "listingaddress: #{@listingaddress1}"
      logger.debug "listingaddress2: #{@listingaddress2}"
      logger.debug "full address: #{@listingaddress}"
      logger.debug "listingcity: #{@listingcity}"
      @lead.message = @lead.message + "  (Inquirer viewed listing at #{@listingaddress} in #{@listingcity} on HomeFinder.com. #{@listingurl})"
      logger.debug "message: #{@lead.message}"
    end

    respond_to do |format|
      if @lead.save
        @lead.consumer_first_name = URI.escape(@lead.consumer_first_name)
        @lead.consumer_last_name = URI.escape(@lead.consumer_last_name)
        @lead.message = URI.escape(@lead.message)
        
          if Rails.env.development? || @lead.test_ind == 'Y'
              @emailsendurl = "http://api.qa.homefinder.com/emailServices/partyLead?id=#{@lead.agent_id}&firstName=#{@lead.consumer_first_name}&lastName=#{@lead.consumer_last_name}&fromEmailAddress=#{@lead.consumer_email}&comment=#{@lead.message}"
          else
              @emailsendurl = "http://api.homefinder.com/emailServices/partyLead?id=#{@lead.agent_id}&firstName=#{@lead.consumer_first_name}&lastName=#{@lead.consumer_last_name}&fromEmailAddress=#{@lead.consumer_email}&comment=#{@lead.message}"
          end
        @emailservicesresponse = JSON.parse(open(@emailsendurl).read)
        logger.debug "emailServices called using URL: #{@emailsendurl}"
        logger.debug "emailServices response: #{@emailservicesresponse}"
        if @emailservicesresponse['status']['code'] == 200
          format.html { redirect_to @lead }
          format.json { render json: @lead, status: :created, location: @lead }
        end
      else
        format.html { render action: "new" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /leads/1
  # PUT /leads/1.json
  def update
    @lead = Lead.find(params[:id])

    respond_to do |format|
      if @lead.update_attributes(params[:lead])
        format.html { redirect_to @lead, notice: 'Lead was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lead.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leads/1
  # DELETE /leads/1.json
  def destroy
    @lead = Lead.find(params[:id])
    @lead.destroy

    respond_to do |format|
      format.html { redirect_to leads_url }
      format.json { head :no_content }
    end
  end
end
