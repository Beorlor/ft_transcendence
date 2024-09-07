require 'socket'
require_relative 'config/environment'
require_relative 'app/controllers/ssr_controller'

server = TCPServer.new('0.0.0.0', 4568)
puts "Ruby SSR server running on port 4568"

loop do
  client = server.accept
  method, path, headers, body = SsrController.parse_request(client)

  case method
  when 'GET'
    SsrController.render_ssr(client, path)
  else
    SsrController.not_found(client)
  end

  client.close
end
