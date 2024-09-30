require 'socket'
require_relative 'app/controllers/auth_controller'
require_relative 'app/controllers/token_controller'
require_relative 'app/controllers/user_controller'
require_relative 'app/config/request_helper'

server = TCPServer.new('0.0.0.0', 4567)
puts "Ruby User Management server running on port 4567"

authController = AuthController.new
tokenController = TokenController.new
userController = UserController.new


loop do
  begin
    client = server.accept
    method, path, headers, cookies, body = RequestHelper.parse_request(client)

    foundAuth = authController.route_request(client, method, path, body, headers, cookies)
    foundToken = tokenController.route_request(client, method, path, body, headers, cookies)
    foundUser = userController.route_request(client, method, path, body, headers, cookies)

    if foundUser == 1 && foundToken == 1 && foundAuth == 1
      RequestHelper.not_found(client)
    end
  rescue Errno::EPIPE => e
    puts "Erreur : Broken pipe - #{e.message}"
  ensure
    client.close if client
  end
end
