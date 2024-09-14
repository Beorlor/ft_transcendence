require 'socket'
require_relative 'config/environment'
require_relative 'app/controllers/auth_controller'

server = TCPServer.new('0.0.0.0', 4567)
puts "Ruby User Management server running on port 4567"

mainController = MainController.new

loop do
  client = server.accept
  method, path, headers, body = mainController.parse_request(client)

  mainController.route_request(client, method, path, body, headers)

  client.close
end
