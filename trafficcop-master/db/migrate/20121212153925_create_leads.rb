class CreateLeads < ActiveRecord::Migration
  def change
    create_table :leads do |t|
      t.integer :agent_id
      t.string :consumer_first_name
      t.string :consumer_last_name
      t.string :consumer_email
      t.string :consumer_phone
      t.text :message
      t.integer :response_code
      t.boolean :test_ind
      t.string :listing_id

      t.timestamps
    end
  end
end
