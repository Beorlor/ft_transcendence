require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require 'uri'
require 'net/http'
require 'json'

class MainController
  def self.parse_request(client)
    request = client.readpartial(2048)
    method, path, _version = request.lines[0].split
    headers = {}
    body = nil

    request.lines[1..-1].each do |line|
      if line == "\r\n"
        body = request.lines[request.lines.index(line) + 1..-1].join
        break
      end

      header, value = line.split(': ', 2)
      headers[header] = value.strip
    end

    [method, path, headers, body]
  end

  def self.route_request(client, method, path, body, headers)
    uri = URI.parse(path)
    query_string = uri.query
    params = query_string ? URI.decode_www_form(query_string).to_h : {}
    clean_path = uri.path
  
    case [method, clean_path]
    when ['POST', '/auth/signup']
      signup(client, body)
    when ['POST', '/auth/login']
      login(client, body)
    when ['POST', '/auth/refresh']
      refresh(client, body)
    when ['GET', '/auth/verify']
      verify(client, headers)
    when ['GET', '/user']
      get_user(client)
    when ['PUT', '/user']
      update_user(client)
    when ['DELETE', '/user']
      delete_user(client)
    when ['GET', '/auth/logwith42']
      logwith42(client)
    when ['GET', '/auth/callback']
      handle_callback(client, params)
    else
      not_found(client)
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

  def self.handle_callback(client, params)
    authorization_code = params['code']
  
    if authorization_code
      access_token = get_access_token(client, authorization_code)
      if access_token
        get_user_info(client, access_token)
      else
        respond(client, 500, 'Failed to obtain access token')
      end
    else
      respond(client, 400, 'Authorization failed')
    end
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
      respond(client, 200, "User info: #{user_info}")
    else
      respond(client, 500, "Failed to fetch user info")
    end
  end
  

  def self.logwith42(client)
    redirect_url = "https://api.intra.42.fr/oauth/authorize?client_id=u-s4t2ud-3d09d3fd60430ebcfc5a7129e2f5e6715d915c409f6f4aa19a5340c8893c073f&redirect_uri=http%3A%2F%2Flocalhost%3A8082%2Fauth%2Fcallback&response_type=code"
    
    client.write "HTTP/1.1 302 Found\r\n"
    client.write "Location: #{redirect_url}\r\n"
    client.write "\r\n"
  end

  def self.signup(client, body)
    CustomLogger.log("User signup request received.")
    respond(client, 200, "Signup successful.")
  end

  def self.login(client, body)
    CustomLogger.log("User login request received.")
    tokens = TokenManager.generate_tokens(body)
    respond(client, 200, tokens)
  end

  def self.refresh(client, body)
    CustomLogger.log("Token refresh request received.")
    new_access_token = TokenManager.refresh_access_token(body)
    respond(client, 200, { access_token: new_access_token })
  end

  def self.verify(client, headers)
	CustomLogger.log("Token verification request received.")

	# Check if the Authorization header is present
	authorization_header = headers['Authorization']

	if authorization_header.nil? || authorization_header.strip.empty?
	  CustomLogger.log("Authorization header is missing.")
	  respond(client, 400, "Authorization header is missing.")  # 400 Bad Request for missing header
	  return
	end

	# Verify the access token
	if TokenManager.verify_access_token(authorization_header)
	  respond(client, 200, "Access token is valid.")
	else
	  CustomLogger.log("Invalid access token.")
	  respond(client, 401, "Invalid access token.")  # 401 Unauthorized for invalid token
	end
  end


  def self.get_user(client)
    respond(client, 200, "User information")
  end

  def self.update_user(client)
    respond(client, 200, "User updated")
  end

  def self.delete_user(client)
    respond(client, 200, "User deleted")
  end

  def self.not_found(client)
    respond(client, 404, "Not found.")
  end

  private

  def self.respond(client, status, message)
    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: application/json"
    client.puts
    client.puts message.is_a?(String) ? { message: message }.to_json : message.to_json
  end
end
