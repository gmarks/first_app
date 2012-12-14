class AddNextBillingDateToParty < ActiveRecord::Migration
  def change
    add_column :parties, :next_billing_date, :datetime
    add_column :parties, :subscriber_since, :datetime
    add_column :parties, :hf_party_page, :string
  end
end