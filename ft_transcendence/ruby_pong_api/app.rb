require 'socket'
require_relative 'app/controllers/pong_controller'
require_relative 'app/config/request_helper'

server = TCPServer.new('0.0.0.0', 4571)
pong_controller = PongController.new

loop do
  begin
    client = server.accept
    method, path, headers, cookies, body = RequestHelper.parse_request(client)
    
    status_pong = pong_controller.route_request(client, method, path, body, headers, cookies)

    if status_pong == 1
      RequestHelper.not_found(client)
    end
  rescue Errno::EPIPE => e
    puts "Erreur : Broken pipe - #{e.message}"
  ensure
    client.close if client
  end
end
