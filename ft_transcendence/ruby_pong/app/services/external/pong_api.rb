require 'json'
require 'em-http-request'

class PongApi

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def create_game(api_url, player1, player2, &callback)
    http = EM::HttpRequest.new(api_url).post(
      body: { player1: player1, player2: player2 }.to_json,
      head: { 'Content-Type' => 'application/json' }
    )
    http.callback do
      if http.response_header.status == 200
        callback.call(JSON.parse(http.response)) if callback
      else
        callback.call(nil) if callback
      end
    end
  
    http.errback do
      callback.call(nil) if callback
    end
  end

  def get_game_history(api_url, user_id, &callback)
    http = EM::HttpRequest.new(api_url).post(
      body: { user_id: user_id }.to_json,
      head: { 'Content-Type' => 'application/json' }
    )
  
    http.callback do
      if http.response_header.status == 200
        callback.call(JSON.parse(http.response)) if callback
      else
        callback.call(nil) if callback
      end
    end
  
    http.errback do
      callback.call(nil) if callback
    end
  end
end