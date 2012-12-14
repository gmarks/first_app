class AddZipCodeIdToBuyerLeadsZipCode < ActiveRecord::Migration
  def change
    #add zip_code_id column
    add_column :buyer_leads_zip_codes, :zip_code_id, :integer
    
    #now create zip_codes from current data
    BuyerLeadsZipCode.all.each do |blz|
      #check for existing
      zip = ZipCode.find_by_zip_code(blz.zip_code)
      #create if none exist
      zip = ZipCode.create(:zip_code => blz.zip_code) if !zip
      blz.zip_code_id = zip.id
    end
    
    #now drop existing zip col
    remove_column :buyer_leads_zip_codes, :zip_code
  end
end