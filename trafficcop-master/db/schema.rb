# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121212222528) do

  create_table "buyer_leads_zip_codes", :force => true do |t|
    t.integer  "party_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "zip_code_id"
    t.integer  "dfp_line_item_id"
  end

  create_table "google_auth_tokens", :force => true do |t|
    t.string   "access_token"
    t.string   "current_code"
    t.string   "refresh_token"
    t.integer  "token_expires_in"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "leads", :force => true do |t|
    t.integer  "agent_id"
    t.string   "consumer_first_name"
    t.string   "consumer_last_name"
    t.string   "consumer_email"
    t.string   "consumer_phone"
    t.text     "message"
    t.integer  "response_code"
    t.boolean  "test_ind"
    t.string   "listing_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "line_items", :force => true do |t|
    t.string   "name"
    t.string   "target_platform"
    t.string   "inventory_sizes"
    t.string   "line_item_type"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "custom_criteria"
    t.string   "comment"
    t.integer  "units_bought"
    t.string   "unit_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "parties", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "hf_party_id"
    t.string   "hf_party_type"
    t.string   "hf_party_image_url"
    t.integer  "mtd_emails",                     :default => 0
    t.integer  "mtd_calls",                      :default => 0
    t.integer  "mtd_unique_emails",              :default => 0
    t.integer  "mtd_unique_calls",               :default => 0
    t.datetime "next_billing_date"
    t.datetime "subscriber_since"
    t.string   "hf_party_page"
    t.text     "recurly_addon_array"
    t.string   "alternate_recurly_account_code"
    t.integer  "mtd_pageviews"
    t.integer  "number_of_listings",             :default => 0
    t.boolean  "is_spw_customer",                :default => false
    t.boolean  "is_party_lead_customer",         :default => false
  end

  create_table "zip_codes", :force => true do |t|
    t.string   "zip_code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
