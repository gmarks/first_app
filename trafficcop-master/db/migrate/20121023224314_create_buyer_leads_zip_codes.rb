class CreateBuyerLeadsZipCodes < ActiveRecord::Migration
  def change
    create_table :buyer_leads_zip_codes do |t|
      t.string :zip_code
      t.integer :party_id

      t.timestamps
    end
  end
end
