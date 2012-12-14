class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.string :name
      t.string :target_platform
      t.string :inventory_sizes
      t.string :type
      t.datetime :start_time
      t.datetime :end_time
      t.string :custom_criteria
      t.string :comment
      t.integer :units_bought
      t.string :unit_type

      t.timestamps
    end
  end
end
