require 'socket'

server = TCPServer.new('0.0.0.0', 4571)

loop do
  begin
    client = server.accept
    method, path, headers, cookies, body = RequestHelper.parse_request(client)

	#LOGIC STARTS HERE
    end
  rescue Errno::EPIPE => e
    puts "Erreur : Broken pipe - #{e.message}"
  ensure
    client.close if client
  end
end
