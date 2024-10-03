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
    when ['POST', '/api/pong/create_game']
      create_game(client, body)
    else
      return 1
    end
    return 0
  end

  def create_game(client, body)
    status = @pong_manager.create_game(body)
    RequestHelper.respond(client, 200, { success: "Bien joué !"})
  end
end