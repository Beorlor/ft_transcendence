require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require_relative '../services/user_manager'
require 'uri'
require 'net/http'
require 'json'

class UserController

  def initialize(logger = Logger.new, user_manager = UserManager.new, token_manager = TokenManager.new)
    @logger = logger
    @token_manager = token_manager
    @user_manager = user_manager
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
    user_id_match = clean_path.match(%r{^/user/(\d+)$})
    if user_id_match
      user_id = user_id_match[1]
      case [method]
      when ['GET']
        get_user(client, user_id)
      when ['PUT']
        update_user(client)
      when ['DELETE']
        delete_user(client)
      else
        @logger.log('UserController', "No route found for: #{method} #{clean_path}")
        RequestHelper.not_found(client)
      end
    else
      case [method, clean_path]
      when ['GET', '/user/me']
        get_user(client, @token_manager.get_user_id(headers['Authorization']))
      else
        return 1
      end
    end
    return 0
  end
  
  def get_user(client, user_id)
    @logger.log('UserController', "Fetching user with ID: #{user_id}")
    status = @user_manager.get_user(user_id)
    RequestHelper.respond(client, status[:code], status)
  end

  def update_user(client)
    RequestHelper.respond(client, 200, "User updated")
  end

  def delete_user(client)
    RequestHelper.respond(client, 200, "User deleted")
  end
end
