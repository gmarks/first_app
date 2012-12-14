class AddHfPartyIdToParty < ActiveRecord::Migration
  def change
    add_column :parties, :hf_party_id, :string
    add_column :parties, :hf_party_type, :string
    add_column :parties, :hf_party_image_url, :string
  end
end