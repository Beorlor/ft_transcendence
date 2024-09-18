require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require_relative '../services/auth_manager'
require_relative '../config/request_helper'
require 'uri'
require 'net/http'
require 'json'

class AuthController

  def initialize(logger = Logger.new, auth_manager = AuthManager.new, token_manager = TokenManager.new)
    @logger = logger
    @auth_manager = auth_manager
    @token_manager = token_manager
  end

  def route_request(client, method, path, body, headers)
    if path.nil? || path.empty?
      RequestHelper.not_found(client)
      return
    end

    begin
      uri = URI.parse(path)
    rescue URI::InvalidURIError => e
		@logger.log('AuthController', "Error parsing URI: #{e.message}")
		RequestHelper.not_found(client)
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
    when ['GET', '/auth/logwith42']
      logwith42(client)
    when ['GET', '/auth/callback']
      handle_callback(client, params)
	when ['POST', '/auth/validate-code']
		validate_code(client, body)
    else
      return 1
    end
    return 0
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
          RequestHelper.respond(client, 200, token)
        else
          RequestHelper.respond(client, 500, {error:'Failed to fetch user info'})
        end
      else
        RequestHelper.respond(client, 500, {error:'Failed to obtain access token'})
      end
    else
      RequestHelper.respond(client, 400, {error:'Authorization failed'})
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
      RequestHelper.respond(client, status[:code], status)
      return
    end
    tokens = @token_manager.generate_tokens(status[:user])
    status[:tokens] = tokens
    RequestHelper.respond(client, 200, status)
  end

  def login(client, body)
    status = @auth_manager.login(body)
    tokens = @token_manager.generate_tokens(status[:user])
    if status[:error]
      RequestHelper.respond(client, status[:code], status)
      return
    end
    status[:tokens] = tokens
    RequestHelper.respond(client, 200, status)
  end

  def validate_code(client, body)
    user_id = body['user_id']
    code = body['code']
    status = @auth_manager.validate_code(user_id, code)
    RequestHelper.respond(client, status[:code], status)
  end

end
