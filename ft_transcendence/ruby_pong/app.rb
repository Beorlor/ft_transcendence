require 'em-websocket'
require 'eventmachine'
require_relative 'app/log/custom_logger'
require_relative 'app/controllers/pong_controller'

class AppServer
  def initialize(logger = Logger.new, pongController = PongController.new)
    @logger = logger
    @pongController = pongController
  end

  def start
    EM.run do
      @logger.log('APP', "Starting server on localhost:4569")
      EM::WebSocket.run(host: "0.0.0.0", port: 4569) do |ws|
        ws.onopen do |event|
          @pongController.route_request(ws, event)
        end
      end
    end
  end
end

AppServer.new.start