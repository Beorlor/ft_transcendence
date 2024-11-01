require_relative '../services/token_manager'
require_relative '../log/custom_logger'
require_relative '../services/friend_manager'
require_relative '../config/request_helper'
require 'uri'
require 'net/http'
require 'json'

class FriendController

  def initialize(logger = Logger.new, friend_manager = FriendManager.new, token_manager = TokenManager.new)
    @logger = logger
    @token_manager = token_manager
    @friend_manager = friend_manager
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
    user_page_match = clean_path.match(%r{^/api/friends/(\d+)$})
    if user_page_match
      user_id = user_page_match[1]
      case [method]
      when ['GET']
        get_friends(client, user_id)
      end
    else
      case [method, clean_path]
        when ['POST', '/api/add-friend']
          add_friend(client, body, cookies)
        else
          return 1
        end
    end
    return 0
  end

  def add_friend(client, body, cookies)
    user_id = @token_manager.get_user_id(cookies['access_token'])
    status = @friend_manager.add_friend(user_id, body)
    if status[:error]
      RequestHelper.respond(client, status[:code], {error: status[:error]})
      return
    end
    RequestHelper.respond(client, status[:code], {success: status[:success]})
  end

  def get_friends(client, user_id)
    friends = @friend_manager.get_friends(user_id)
    RequestHelper.respond(client, 200, friends)
  end
end
