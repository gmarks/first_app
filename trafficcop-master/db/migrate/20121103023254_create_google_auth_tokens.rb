class CreateGoogleAuthTokens < ActiveRecord::Migration
  def change
    create_table :google_auth_tokens do |t|
      t.string :access_token
      t.string :current_code
      t.string :refresh_token
      t.integer :token_expires_in

      t.timestamps
    end
  end
end
