require 'socket'
require_relative 'config/environment'
require_relative 'app/controllers/main_controller'

server = TCPServer.new('0.0.0.0', 4567)
puts "Ruby User Management server running on port 4567"

loop do
  client = server.accept
  method, path, headers, body = MainController.parse_request(client)

  case [method, path]
  when ['POST', '/auth/signup']
    MainController.signup(client, body)
  when ['POST', '/auth/login']
    MainController.login(client, body)
  when ['POST', '/auth/refresh']
    MainController.refresh(client, body)
  when ['GET', '/auth/verify']
    MainController.verify(client, headers)
  else
    MainController.not_found(client)
  end

  client.close
end
