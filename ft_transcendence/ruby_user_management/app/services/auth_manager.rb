require_relative '../repository/auth_repository'
require 'uri'
require 'net/http'
require 'json'

module AuthManager

  def self.registerUser42(user)
    Logger.log('AuthManager', "Registering user with email #{user['email']}")
    user_info = {
      username: user['login'],
      email: user['email'],
      role: 0,
      login_type: 1,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    AuthRepository.registerUser42(user_info)
  end

  def self.get_user_info(client, access_token)
    Logger.log('AuthManager', "Getting user info with access token: #{access_token}")
    uri = URI.parse("https://api.intra.42.fr/v2/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code == '200'
      Logger.log('AuthManager', "User info retrieved successfully")
      user_info = JSON.parse(response.body)
      return user_info
    else
      Logger.log('AuthManager', "Error while getting user info: #{response.message}")
      return nil
    end
  end

  def self.get_access_token(client, authorization_code)
    Logger.log('AuthManager', "Getting access token with authorization code: #{authorization_code}")
    uri = URI.parse("https://api.intra.42.fr/oauth/token")

    params = {
      grant_type: 'authorization_code',
      client_id: ENV['API_CLIENT'],
      client_secret: ENV['API_SECRET'],
      code: authorization_code,
      redirect_uri: 'http://localhost:8082/auth/callback'
    }
  
    response = Net::HTTP.post_form(uri, params)
  
    if response.is_a?(Net::HTTPSuccess)
      Logger.log('AuthManager', "Access token retrieved successfully")
      response_body = JSON.parse(response.body)
      access_token = response_body['access_token']
      access_token
    else
      Logger.log('AuthManager', "Error while getting access token: #{response.message}")
      nil
    end
  end

end