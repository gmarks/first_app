class AddLineitemIdToBuyerLeadsZipCode < ActiveRecord::Migration
  def change
    add_column :buyer_leads_zip_codes, :dfp_line_item_id, :integer
  end
end