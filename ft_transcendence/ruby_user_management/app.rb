require 'socket'
require_relative 'config/environment'
require_relative 'app/controllers/auth_controller'

server = TCPServer.new('0.0.0.0', 4567)
puts "Ruby User Management server running on port 4567"

loop do
  client = server.accept
  method, path, headers, body = MainController.parse_request(client)

  MainController.route_request(client, method, path, body, headers)

  client.close
end
