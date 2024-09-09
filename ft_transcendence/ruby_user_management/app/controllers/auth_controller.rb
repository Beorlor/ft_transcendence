require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require_relative '../services/auth_manager'
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

  def self.handle_callback(client, params)
    authorization_code = params['code']
  
    if authorization_code
      access_token = AuthManager.get_access_token(client, authorization_code)
      if access_token
        AuthManager.get_user_info(client, access_token)
      else
        respond(client, 500, 'Failed to obtain access token')
      end
    else
      respond(client, 400, 'Authorization failed')
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

    authorization_header = headers['Authorization']

    if authorization_header.nil? || authorization_header.strip.empty?
      CustomLogger.log("Authorization header is missing.")
      respond(client, 400, "Authorization header is missing.")
      return
    end

    if TokenManager.verify_access_token(authorization_header)
      respond(client, 200, "Access token is valid.")
    else
      CustomLogger.log("Invalid access token.")
      respond(client, 401, "Invalid access token.")
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
