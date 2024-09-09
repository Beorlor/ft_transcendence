module AuthManager

  def self.get_user_info(client, access_token)
    uri = URI.parse("https://api.intra.42.fr/v2/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code == '200'
      user_info = JSON.parse(response.body)
      respond(client, 200, "User info: #{user_info}")
    else
      respond(client, 500, "Failed to fetch user info")
    end
  end

  def self.get_access_token(client, authorization_code)
    uri = URI.parse("https://api.intra.42.fr/oauth/token")
    
    params = {
      grant_type: 'authorization_code',
      client_id: 'u-s4t2ud-3d09d3fd60430ebcfc5a7129e2f5e6715d915c409f6f4aa19a5340c8893c073f',
      client_secret: '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',
      code: authorization_code,
      redirect_uri: 'http://localhost:8082/auth/callback'
    }
  
    response = Net::HTTP.post_form(uri, params)
  
    if response.is_a?(Net::HTTPSuccess)
      response_body = JSON.parse(response.body)
      access_token = response_body['access_token']
      access_token
    else
      CustomLogger.log("Failed to fetch access token: #{response.body}")
      client.respond_with_error("Failed to fetch access token")
      nil
    end
  end

end