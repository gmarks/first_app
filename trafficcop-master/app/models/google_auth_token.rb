class GoogleAuthToken < ActiveRecord::Base
  attr_accessible :access_token, :current_code, :refresh_token, :token_expires_in
  def acquire_tokens_with_code code
    res = Typhoeus::Request.post('https://accounts.google.com/o/oauth2/token', :params => {
                                   'code' => code,
                                   'client_id' => Trafficcop::Application::CLIENT_ID,
                                   'client_secret' => Trafficcop::Application::CLIENT_SECRET,
                                   'redirect_uri' => Trafficcop::Application::REDIRECT_URI,
                                   'grant_type' => 'authorization_code'
    })
    results = JSON.parse(res.body)
    write_attribute(:access_token, results['access_token'])
    write_attribute(:token_expires_in, results['expires_in'].to_i + Time.now.to_i)
    save
  end

  def acquire_new_access_token

    res = Typhoeus::Request.post('https://accounts.google.com/o/oauth2/token', :params => {
                                   'client_id' => Trafficcop::Application::CLIENT_ID,
                                   'client_secret' => Trafficcop::Application::CLIENT_SECRET,
                                   'refresh_token' => Trafficcop::Application::GOOGLE_REFRESH_TOKEN,
                                   'grant_type' => 'refresh_token'
    })
  #  binding.pry
    results = JSON.parse(res.body)

    write_attribute(:access_token, results['access_token'])
    write_attribute(:token_expires_in, results['expires_in'].to_i + Time.now.to_i)
    save
  end

  def get_access_token
    # If there's less than 10 mins left for the access token, refresh it.
    if 600 >= (Time.at(read_attribute(:token_expires_in)).to_i - Time.now.to_i)
      acquire_new_access_token
    end
    read_attribute(:access_token)
  end

end
