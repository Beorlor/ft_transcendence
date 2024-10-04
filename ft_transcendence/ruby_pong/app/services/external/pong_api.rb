require 'net/http'
require 'json'

class PongApi

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def create_game(api_url, player1, player2)
    uri = URI(api_url)
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = "player1=#{player1}; player2=#{player2}"
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.start do |http|
      http.request(req)
    end
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      nil
    end
  end

  def get_game_history(api_url, user_id)
    uri = URI(api_url)
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = "user_id=#{user_id}"
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.start do |http|
      http.request(req)
    end
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    else
      nil
    end
  end
end