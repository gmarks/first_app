class AddAddOnHashToParty < ActiveRecord::Migration
  def change
    add_column :parties, :recurly_addon_array, :text
  end
end