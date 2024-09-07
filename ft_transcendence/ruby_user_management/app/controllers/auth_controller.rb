require_relative '../services/token_manager'
require_relative '../log/custom_logger'

class MainController
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

  def self.signup(client, body)
    CustomLogger.log("User signup request received.")
    # Your signup logic
    respond(client, 200, "Signup successful.")
  end

  def self.login(client, body)
    CustomLogger.log("User login request received.")
    # Your login logic
    respond(client, 200, "Login successful.")
  end

  def self.refresh(client, body)
    CustomLogger.log("Token refresh request received.")
    # Your refresh token logic
    respond(client, 200, "Token refreshed.")
  end

  def self.verify(client, headers)
    CustomLogger.log("Token verification request received.")
    # Your token verification logic
    respond(client, 200, "Token verified.")
  end

  def self.not_found(client)
    respond(client, 404, "Not found.")
  end

  private

  def self.respond(client, status, message)
    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: application/json"
    client.puts
    client.puts({ message: message }.to_json)
  end
end
