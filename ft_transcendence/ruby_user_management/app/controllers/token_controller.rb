require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require_relative '../services/auth_manager'
require 'uri'
require 'net/http'
require 'json'

class TokenController

  def initialize(logger = Logger.new, token_manager = TokenManager.new)
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
      puts "Erreur lors de l'analyse de l'URI : #{e.message}"
      RequestHelper.not_found(client)
      return
    end
  
    query_string = uri.query
    params = query_string ? URI.decode_www_form(query_string).to_h : {}
    clean_path = uri.path
  
    case [method, clean_path]
    when ['POST', '/auth/refresh']
      refresh(client, body)
    when ['GET', '/auth/verify']
      verify(client, headers)
    else
      return 1
    end
    return 0
  end

  def refresh(client, body)
    new_access_token = @token_manager.refresh_access_token(body)
    RequestHelper.respond(client, 200, { access_token: new_access_token })
  end

  def verify(client, headers)
    authorization_header = headers['Authorization']

    if authorization_header.nil? || authorization_header.strip.empty?
      RequestHelper.respond(client, 400, "Authorization header is missing.")
      return
    end

    if @token_manager.verify_access_token(authorization_header)
      RequestHelper.respond(client, 200, "Access token is valid.")
    else
      RequestHelper.respond(client, 401, "Invalid access token.")
    end
  end
end
