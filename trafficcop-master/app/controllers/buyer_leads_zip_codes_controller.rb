class BuyerLeadsZipCodesController < ApplicationController
  include AdwordsHelper
  include BuyerLeadsZipCodesHelper

  before_filter :admin_required
  before_filter :load_party

  # GET /buyer_leads_zip_codes
  # GET /buyer_leads_zip_codes.json
  def index
    if @party 
        @buyer_leads_zip_codes = @party.buyer_leads_zip_codes
    else
      @buyer_leads_zip_codes = BuyerLeadsZipCode.all
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @buyer_leads_zip_codes }
    end
  end

  # GET /buyer_leads_zip_codes/1
  # GET /buyer_leads_zip_codes/1.json
  def show
    @buyer_leads_zip_code = BuyerLeadsZipCode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @buyer_leads_zip_code }
    end
  end

  def estimate_zips

  end

  # GET /buyer_leads_zip_codes/new
  # GET /buyer_leads_zip_codes/new.json
  def new
    @buyer_leads_zip_code = BuyerLeadsZipCode.new
    @zip_code = ZipCode.new
    @zip_code[:zip_code] =  params[:zip_code]
    @impression_hash = BuyerLeadsZipCodesHelper.dfp_estimation(@zip_code)
    if @impression_hash == "Invalid ZipCode"
      redirect_to(:back, :notice => @impression_hash) and return
    end
#    @adwords_estimation_hash = AdwordsHelper.estimate_by_zip_code(@zip_code.zip_code)
#    @zip_code.save

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @buyer_leads_zip_code }
    end
  end

  def initiate_purchase
    @zip_code = ZipCode.new
    @zip_code[:zip_code] =  params[:zip_code]
    @party = params[:party_id]
    @impression_hash = BuyerLeadsZipCodesHelper.dfp_estimation(@zip_code)
    if @impression_hash == "Invalid ZipCode"
      redirect_to(:back, :notice => @impression_hash) and return
    end
    @adwords_estimation_hash =  AdwordsHelper.estimate_by_zip_code(@zip_code.zip_code) 
    @price = (@adwords_estimation_hash[:mean_clicks] * @adwords_estimation_hash[:mean_total_cost])
  end

  # GET /buyer_leads_zip_codes/1/edit
  def edit
    @buyer_leads_zip_code = BuyerLeadsZipCode.find(params[:id])
  end

  # POST /buyer_leads_zip_codes
  # POST /buyer_leads_zip_codes.json
  def create
    @buyer_leads_zip_code = BuyerLeadsZipCode.new(params[:buyer_leads_zip_code])
    @buyer_leads_zip_code.party = @party
    

    respond_to do |format|
      if @buyer_leads_zip_code.save
        format.html { redirect_to @buyer_leads_zip_code, notice: 'Buyer leads zip code was successfully created.' }
        format.json { render json: @buyer_leads_zip_code, status: :created, location: @buyer_leads_zip_code }
      else
        format.html { render action: "new" }
        format.json { render json: @buyer_leads_zip_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /buyer_leads_zip_codes/1
  # PUT /buyer_leads_zip_codes/1.json
  def update
    @buyer_leads_zip_code = BuyerLeadsZipCode.find(params[:id])

    respond_to do |format|
      if @buyer_leads_zip_code.update_attributes(params[:buyer_leads_zip_code])
        format.html { redirect_to @buyer_leads_zip_code, notice: 'Buyer leads zip code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @buyer_leads_zip_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buyer_leads_zip_codes/1
  # DELETE /buyer_leads_zip_codes/1.json
  def destroy
    @buyer_leads_zip_code = BuyerLeadsZipCode.find(params[:id])
    @buyer_leads_zip_code.destroy

    respond_to do |format|
      format.html { redirect_to buyer_leads_zip_codes_url }
      format.json { head :no_content }
    end
  end

  private
  def load_party
    @party = Party.find(params[:party_id]) if params[:party_id]
  end

end
