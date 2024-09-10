require_relative '../repository/auth_repository'
require 'uri'
require 'net/http'
require 'json'

module AuthManager

  def self.registerUser42(user)
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
    uri = URI.parse("https://api.intra.42.fr/v2/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code == '200'
      user_info = JSON.parse(response.body)
      return user_info
    else
      return nil
    end
  end

  def self.get_access_token(client, authorization_code)
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
      response_body = JSON.parse(response.body)
      access_token = response_body['access_token']
      access_token
    else
      client.respond_with_error("Failed to fetch access token")
      nil
    end
  end

end