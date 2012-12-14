class AddListingCountsToParty < ActiveRecord::Migration
  def change
    add_column :parties, :number_of_listings, :integer, :default => 0
  end
end