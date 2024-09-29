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

  def route_request(client, method, path, body, headers, cookies)
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
    user_id_match = clean_path.match(%r{^/api/user/(\d+)$})
    user_page_match = clean_path.match(%r{^/api/users/(\d+)$})
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
    elsif clean_path == '/api/users'
      case [method]
      when ['GET']
        get_users_paginated(client)
      else
        @logger.log('UserController', "No route found for: #{method} #{clean_path}")
        RequestHelper.not_found(client)
      end
    elsif user_page_match
      user_page = user_page_match[1]
      case [method]
      when ['GET']
        get_users_paginated(client, user_page)
      else
        @logger.log('UserController', "No route found for: #{method} #{clean_path}")
        RequestHelper.not_found(client)
      end
    else
      case [method, clean_path]
      when ['GET', '/api/user/me']
        @logger.log('UserController', "Fetching user with access_token: #{cookies['access_token']}")
        get_user(client, @token_manager.get_user_id(cookies['access_token']))
      else
        return 1
      end
    end
    return 0
  end

  def get_users_paginated(client, user_page=1)
    @logger.log('UserController', "Fetching users for page: #{user_page}")
    status = @user_manager.get_users_paginated(user_page)
    if status[:code] != 200
      RequestHelper.respond(client, status[:code], { error: status[:error] })
      return
    end
    @logger.log('UserController', "Users found for page: #{user_page}, users: #{status[:users]}")
    RequestHelper.respond(client, status[:code], { users: status[:users] })
  end
  
  def get_user(client, user_id)
    @logger.log('UserController', "Fetching user with ID: #{user_id}")
    status = @user_manager.get_user(user_id)
    RequestHelper.respond(client, status[:code], status)
  end

  def update_user(client)
    RequestHelper.respond(client, 200, { success: "User updated" })
  end

  def delete_user(client)
    RequestHelper.respond(client, 200, { success: "User deleted" })
  end
end
