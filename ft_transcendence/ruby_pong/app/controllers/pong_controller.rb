require_relative '../log/custom_logger'
require_relative '../services/pong'

class PongController
  def initialize(logger = Logger.new, pong = Pong.new)
    @logger = logger
    @pong = pong
  end

  def route_request(client, event)
    path = event.path
    headers = event.headers
    case path
    when '/pongsocket/pong'
      pong(client, headers)
    when '/pongsocket/ranked'
      ranked(client, headers)
    when '/pongsocket/custom'
      client.send('pong custom')
    else
      client.send('Invalid path')
      client.close
    end
  end

  def pong(client, headers)
    @logger.log("pong", "pong normal start matchmaking")
    cookie = headers['Cookie'].split('; ').map { |c| c.split('=', 2) }.to_h
    @pong.matchmaking(client, cookie)
  end

  def ranked(client, headers)
    @logger.log("ranked", "pong ranked start matchmaking")
    cookie = headers['Cookie'].split('; ').map { |c| c.split('=', 2) }.to_h
    @pong.matchmaking(client, cookie, true)
  end

end