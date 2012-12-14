class ZipCodesController < ApplicationController
  # GET /zip_codes
  # GET /zip_codes.json
  def index
    @zip_codes = ZipCode.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @zip_codes }
    end
  end

  # GET /zip_codes/1
  # GET /zip_codes/1.json
  def show
    if params[:id]
      @zip_code = ZipCode.find(params[:id])
    else
      @zip_code = ZipCode.find_by_zip_code(params[:zip_code])
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @zip_code }
    end
  end

  # GET /zip_codes/new
  # GET /zip_codes/new.json
  def new
    @zip_code = ZipCode.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @zip_code }
    end
  end

  # GET /zip_codes/1/edit
  def edit
    @zip_code = ZipCode.find(params[:id])
  end

  # POST /zip_codes
  # POST /zip_codes.json
  def create
    @zip_code = ZipCode.new(params[:zip_code])

    respond_to do |format|
      if @zip_code.save
        format.html { redirect_to @zip_code, notice: 'Zip code was successfully created.' }
        format.json { render json: @zip_code, status: :created, location: @zip_code }
      else
        format.html { render action: "new" }
        format.json { render json: @zip_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /zip_codes/1
  # PUT /zip_codes/1.json
  def update
    @zip_code = ZipCode.find(params[:id])

    respond_to do |format|
      if @zip_code.update_attributes(params[:zip_code])
        format.html { redirect_to @zip_code, notice: 'Zip code was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @zip_code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /zip_codes/1
  # DELETE /zip_codes/1.json
  def destroy
    @zip_code = ZipCode.find(params[:id])
    @zip_code.destroy

    respond_to do |format|
      format.html { redirect_to zip_codes_url }
      format.json { head :no_content }
    end
  end
end
