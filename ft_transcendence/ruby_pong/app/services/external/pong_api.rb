require 'net/http'
require 'json'

class PongApi
  def create_game(api_url, player1, player2)
    uri = URI(api_url)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req.body = { player1: player1, player2: player2 }.to_json
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