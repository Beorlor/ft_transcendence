require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require_relative '../services/auth_manager'
require 'uri'
require 'net/http'
require 'json'

class MainController

  def initialize(logger = Logger.new, auth_manager = AuthManager.new, token_manager = TokenManager.new)
    @logger = logger
    @auth_manager = auth_manager
    @token_manager = token_manager
  end

  def parse_request(client)
    begin
      request = client.readpartial(2048)
    rescue EOFError
      return nil
    end

    return nil if request.lines.empty?

    method, path, _version = request.lines[0].split
    headers = {}
    body = nil

    request.lines[1..-1].each_with_index do |line, index|
      if line.strip.empty?
        body = request.lines[(index + 2)..-1].join
        break
      end
      header, value = line.split(': ', 2)
      headers[header] = value.strip if header && value
    end

    if headers['Content-Type'] && headers['Content-Type'].include?('application/json')
      begin
        body = JSON.parse(body) unless body.nil? || body.strip.empty?
      rescue JSON::ParserError
        return { error: 'Invalid JSON format' }
      end
    end

    [method, path, headers, body]
  end

  def route_request(client, method, path, body, headers)
    if path.nil? || path.empty?
      not_found(client)
      return
    end
  
    begin
      uri = URI.parse(path)
    rescue URI::InvalidURIError => e
      puts "Erreur lors de l'analyse de l'URI : #{e.message}"
      not_found(client)
      return
    end
  
    query_string = uri.query
    params = query_string ? URI.decode_www_form(query_string).to_h : {}
    clean_path = uri.path
  
    case [method, clean_path]
    when ['POST', '/auth/register']
      register(client, body)
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
    when ['POST', '/auth/valid-token']
      valid_token(client, body, headers)
    else
      not_found(client)
    end
  end

  def valid_token(client, body, headers)
    authorization_header = headers['Authorization']
    if authorization_header.nil? || authorization_header.strip.empty?
      respond(client, 400, {error: "Authorization header is missing."})
      return
    end
    payload = @token_manager.verify_access_token(authorization_header)
    @logger.log('MainController', "Decoded payload: #{payload}")
    response = @auth_manager.valid_token(payload, body)
    respond(client, response[:code], response)
  end
  

  def handle_callback(client, params)
    authorization_code = params['code']
    if authorization_code
      access_token = @auth_manager.get_access_token(client, authorization_code)
      if access_token
        user = @auth_manager.get_user_info(client, access_token)
        if user
          user42 = @auth_manager.register_user_42(user);
          token = @token_manager.generate_tokens(user42)
          respond(client, 200, token)
        else
          respond(client, 500, {error:'Failed to fetch user info'})
        end
      else
        respond(client, 500, {error:'Failed to obtain access token'})
      end
    else
      respond(client, 400, {error:'Authorization failed'})
    end
  end
  

  def logwith42(client)
    redirect_url = ENV['REDIR_URL']
    client.write "HTTP/1.1 302 Found\r\n"
    client.write "Location: #{redirect_url}\r\n"
    client.write "\r\n"
  end

  def register(client, body)
    status = @auth_manager.register(body)
    if status[:error]
      respond(client, status[:code], status)
      return
    end
    tokens = @token_manager.generate_tokens(status[:user])
    status[:tokens] = tokens
    respond(client, 200, status)
  end

  def login(client, body)
    status = @auth_manager.login(body)
    tokens = @token_manager.generate_tokens(status[:user])
    if status[:error]
      respond(client, status[:code], status)
      return
    end
    status[:tokens] = tokens
    respond(client, 200, status)
  end

  def refresh(client, body)
    new_access_token = @token_manager.refresh_access_token(body)
    respond(client, 200, { access_token: new_access_token })
  end

  def verify(client, headers)
    authorization_header = headers['Authorization']

    if authorization_header.nil? || authorization_header.strip.empty?
      respond(client, 400, "Authorization header is missing.")
      return
    end

    if @token_manager.verify_access_token(authorization_header)
      respond(client, 200, "Access token is valid.")
    else
      respond(client, 401, "Invalid access token.")
    end
  end


  def get_user(client)
    respond(client, 200, "User information")
  end

  def update_user(client)
    respond(client, 200, "User updated")
  end

  def delete_user(client)
    respond(client, 200, "User deleted")
  end

  def not_found(client)
    respond(client, 404, "Not found.")
  end

  private

  def respond(client, status, message)
    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: application/json"
    client.puts
    client.puts message.is_a?(String) ? { message: message }.to_json : message.to_json
  end
end
