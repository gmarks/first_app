class AddMtdLeadsToParty < ActiveRecord::Migration
  def change
    add_column :parties, :mtd_emails, :integer, :default => 0
    add_column :parties, :mtd_calls, :integer, :default => 0
  end
end