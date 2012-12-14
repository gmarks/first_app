class FixTypeFieldOnLineItem < ActiveRecord::Migration
  def change
    rename_column :line_items, :type, :line_item_type
  end
end
