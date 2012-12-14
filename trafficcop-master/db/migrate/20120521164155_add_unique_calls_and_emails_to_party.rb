class AddUniqueCallsAndEmailsToParty < ActiveRecord::Migration
  def change
    add_column :parties, :mtd_unique_emails, :integer, :default => 0
    add_column :parties, :mtd_unique_calls, :integer, :default => 0
  end
end