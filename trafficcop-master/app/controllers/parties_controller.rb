class PartiesController < ApplicationController
  before_filter :admin_required

  before_filter :load_zip_code


  # GET /parties
  # GET /parties.json
  def index
    #    @parties = Party.order("(COALESCE(mtd_unique_emails,0) + COALESCE(mtd_unique_calls,0)) DESC")
    if @zip_code
      @parties = @zip_code.parties.order("name ASC")
    else
      @parties = Party.order("name ASC")
    end
    @parties_with_leads_count = 0
    @parties.each {|party| @parties_with_leads_count += 1 if party.total_unique_leads > 0 }

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @parties }
    end
  end

  # GET /parties/1
  # GET /parties/1.json
  def show
    @party = Party.find(params[:id])
    @leads_hash = @party.get_mtd_leads
    if @party.next_billing_date
      @start_date = @party.next_billing_date - 1.month
      @end_date = @party.next_billing_date
    else
      @start_date = Date.parse("#{Date.today.year}-#{Date.today.month}-01")
      @end_date = Date.today
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @party }
    end
  end

  # GET /parties/new
  # GET /parties/new.json
  def new
    @party = Party.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @party }
    end
  end

  # GET /parties/1/edit
  def edit
    @party = Party.find(params[:id])
  end

  # POST /parties
  # POST /parties.json
  def create
    @party = Party.new(params[:party])
    @party.get_party_info_from_hf

    respond_to do |format|
      if @party.save
        format.html { redirect_to @party, notice: 'Party was successfully created.' }
        format.json { render json: @party, status: :created, location: @party }
      else
        format.html { render action: "new" }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /parties/1
  # PUT /parties/1.json
  def update
    @party = Party.find(params[:id])

    respond_to do |format|
      if @party.update_attributes(params[:party])
        format.html { redirect_to @party, notice: 'Party was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @party.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /parties/1
  # DELETE /parties/1.json
  def destroy
    @party = Party.find(params[:id])
    @party.destroy

    respond_to do |format|
      format.html { redirect_to parties_url }
      format.json { head :no_content }
    end
  end
  
  def purchase
    @party = params[:party_id]
    @price = params[:price] 
  end


  private
  def load_zip_code
    if params[:zip_code]
      @zip_code = ZipCode.find_by_zip_code(params[:zip_code])
    elsif params[:zip_code_id]
      @zip_code = ZipCode.find(params[:zip_code_id])
    end
  end
end
