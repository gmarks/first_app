class AddRecurlyAccountCodeToParty < ActiveRecord::Migration
  def change
    add_column :parties, :alternate_recurly_account_code, :string
  end
end