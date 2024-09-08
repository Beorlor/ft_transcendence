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

  def self.route_request(client, method, path, body, headers)
    case [method, path]
    when ['POST', '/auth/signup']
      signup(client, body)
    when ['POST', '/auth/login']
      login(client, body)
    when ['POST', '/auth/refresh']
      refresh(client, body)
    when ['GET', '/auth/verify']
      verify(client, headers)
    when ['GET', '/user']
      get_user(client)
    when ['PUT', '/user']
      update_user(client)
    when ['DELETE', '/user']
      delete_user(client)
    else
      not_found(client)
    end
  end

  def self.signup(client, body)
    CustomLogger.log("User signup request received.")
    respond(client, 200, "Signup successful.")
  end

  def self.login(client, body)
    CustomLogger.log("User login request received.")
    tokens = TokenManager.generate_tokens(body)
    respond(client, 200, tokens)
  end

  def self.refresh(client, body)
    CustomLogger.log("Token refresh request received.")
    new_access_token = TokenManager.refresh_access_token(body)
    respond(client, 200, { access_token: new_access_token })
  end

  def self.verify(client, headers)
	CustomLogger.log("Token verification request received.")

	# Check if the Authorization header is present
	authorization_header = headers['Authorization']

	if authorization_header.nil? || authorization_header.strip.empty?
	  CustomLogger.log("Authorization header is missing.")
	  respond(client, 400, "Authorization header is missing.")  # 400 Bad Request for missing header
	  return
	end

	# Verify the access token
	if TokenManager.verify_access_token(authorization_header)
	  respond(client, 200, "Access token is valid.")
	else
	  CustomLogger.log("Invalid access token.")
	  respond(client, 401, "Invalid access token.")  # 401 Unauthorized for invalid token
	end
  end


  def self.get_user(client)
    respond(client, 200, "User information")
  end

  def self.update_user(client)
    respond(client, 200, "User updated")
  end

  def self.delete_user(client)
    respond(client, 200, "User deleted")
  end

  def self.not_found(client)
    respond(client, 404, "Not found.")
  end

  private

  def self.respond(client, status, message)
    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: application/json"
    client.puts
    client.puts message.is_a?(String) ? { message: message }.to_json : message.to_json
  end
end
