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
      @logger.log('PONG', "Received ping from #{headers['Origin']}")
      pong(client, headers)
    when '/pongsocket/ranked'
      @logger.log('PONG', "Received ping from #{headers['Origin']} for ranked")
      ranked(client, headers)
    when '/pongsocket/custom'
      @logger.log('PONG', "Received ping from #{headers['Origin']} for custom")
      client.send('pong custom')
    else
      client.send('Invalid path')
      client.close
    end
  end

  def pong(client, headers)
    @logger.log('PONG', "Received ping from #{headers}")
    cookie = headers['Cookie'].split('; ').map { |c| c.split('=', 2) }.to_h
    @logger.log('PONG', "Received ping with access token #{cookie['access_token']}")
    @pong.matchmaking(client, cookie)
  end

  def ranked(client, headers)
    @logger.log('PONG', "Received ping from #{headers}")
    cookie = headers['Cookie'].split('; ').map { |c| c.split('=', 2) }.to_h
    @logger.log('PONG', "Received ping with access token #{cookie['access_token']}")
    @pong.matchmaking(client, cookie, true)
  end

end