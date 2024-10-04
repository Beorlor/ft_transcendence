require 'uri'
require_relative '../log/custom_logger'
require_relative '../config/request_helper'
require_relative '../services/pong_manager'

class PongController
  def initialize(logger = Logger.new, pong_manager = PongManager.new)
    @logger = logger
    @pong_manager = pong_manager
  end

  def route_request(client, method, path, body, headers, cookies)
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
    @logger.log('PongController', "Received #{method} request for path #{clean_path}")
    case [method, clean_path]
    when ['GET', '/api/pong/create_game']
      create_game(client, cookies)
    when ['GET', '/api/pong/get_game_history']
      get_game_history(client, cookies)
    else
      return 1
    end
    return 0
  end

  def create_game(client, cookies)
    status = @pong_manager.create_game(cookies)
    if status[:code] != 200
      RequestHelper.respond(client, status[:code], { error: status[:message] })
      return
    end
    RequestHelper.respond(client, 200, { game_info: status[:game_info], success: status[:message] })
  end

  def get_game_history(client, cookies)
    @logger.log('PongController', "Getting game history for user #{cookies}")
    in_game = @pong_manager.is_already_playing(cookies["user_id"])
    @logger.log('PongController', "Game found for user #{in_game}")
    if in_game[:game_info].length == 0
      @logger.log('PongController', "No game found for user #{cookies}")
      RequestHelper.respond(client, 200, { no_game: 'No game found' })
      return
    end
    @logger.log('PongController', "Game found for user #{cookies}")
    RequestHelper.respond(client, 200, { game_info: in_game[:game_info], success: 'Game found' })
  end
end