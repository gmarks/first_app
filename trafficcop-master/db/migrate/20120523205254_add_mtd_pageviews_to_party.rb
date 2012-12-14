class AddMtdPageviewsToParty < ActiveRecord::Migration
  def change
    add_column :parties, :mtd_pageviews, :integer
  end
end