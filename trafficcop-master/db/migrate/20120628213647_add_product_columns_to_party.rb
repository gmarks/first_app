class AddProductColumnsToParty < ActiveRecord::Migration
  def change
    add_column :parties, :is_spw_customer, :boolean, :default => false
    add_column :parties, :is_party_lead_customer, :boolean, :default => false
  end
end