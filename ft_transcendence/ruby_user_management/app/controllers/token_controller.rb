require_relative '../services/token_manager'
require_relative '../log/custom_logger'

class TokenController
  def initialize(logger = Logger.new, token_manager = TokenManager.new(logger))
    @logger = logger
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
      @logger.log('TokenController', "Error parsing URI: #{e.message}")
      RequestHelper.not_found(client)
      return
    end

    query_string = uri.query
    params = query_string ? URI.decode_www_form(query_string).to_h : {}
    clean_path = uri.path

    case [method, clean_path]
    when ['POST', '/auth/refresh']
      refresh_tokens(client, body)
    when ['GET', '/auth/verify-token-user']
      verify_token_user(client, headers)
    when ['GET', '/auth/verify-token-user-code']
      verify_token_user_code(client, headers)
    when ['GET', '/auth/verify-token-admin']
      verify_token_admin(client, headers)
    else
      return 1
    end
    return 0
  end

  def refresh_tokens(client, body)
    refresh_token = body['refresh_token']
    tokens = @token_manager.refresh_tokens(refresh_token)
    if tokens
      RequestHelper.respond(client, 200, tokens)
    else
      RequestHelper.respond(client, 401, { error: 'Invalid refresh token.' })
    end
  end

  def verify_token_user(client, headers)
    authorization_header = headers['Authorization']
    payload = @token_manager.verify_access_token(authorization_header)
    if payload
      RequestHelper.respond(client, 200, "Access token is valid.")
    else
      RequestHelper.respond(client, 401, "Invalid access token.")
    end
  end

  def verify_token_user_code(client, headers)
    authorization_header = headers['Authorization']
    payload = @token_manager.verify_token_user_code(authorization_header)
    if payload
      RequestHelper.respond(client, 200, "Access token is valid (state can be false).")
    else
      RequestHelper.respond(client, 401, "Invalid access token.")
    end
  end

  def verify_token_admin(client, headers)
    authorization_header = headers['Authorization']
    payload = @token_manager.verify_admin_token(authorization_header)
    if payload
      RequestHelper.respond(client, 200, "Admin access token is valid.")
    else
      RequestHelper.respond(client, 401, "Invalid access token.")
    end
  end
end
