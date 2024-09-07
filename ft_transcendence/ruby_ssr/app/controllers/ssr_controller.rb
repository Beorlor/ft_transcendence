require_relative '../log/custom_logger'

class SsrController
  def self.parse_request(client)
    request = client.readpartial(2048)
    method, path, _version = request.lines[0].split
    headers = {}
    body = nil

    request.lines[1..-1].each do |line|
      if line == "\r\n"
        body = request.lines[request.lines.index(line) + 1..-1].join
        break
      end

      header, value = line.split(': ', 2)
      headers[header] = value.strip
    end

    [method, path, headers, body]
  end

  def self.render_ssr(client, path)
    CustomLogger.log("Rendering SSR for #{path}")
    # SSR rendering logic (could be static HTML for now)
    respond(client, 200, "<html><body><h1>SSR Page for #{path}</h1></body></html>")
  end

  def self.not_found(client)
    respond(client, 404, "Not found.")
  end

  private

  def self.respond(client, status, message)
    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: text/html"
    client.puts
    client.puts(message)
  end
end
