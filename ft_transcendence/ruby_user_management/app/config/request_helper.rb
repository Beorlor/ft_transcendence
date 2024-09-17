require 'json'

module RequestHelper
  def self.parse_request(client)
    begin
      request = client.readpartial(2048)
    rescue EOFError
      return nil
    end
    return nil if request.lines.empty?
    method, path, _version = request.lines[0].split
    headers = {}
    body = nil

    request.lines[1..-1].each_with_index do |line, index|
      if line.strip.empty?
        body = request.lines[(index + 2)..-1].join
        break
      end
      header, value = line.split(': ', 2)
      headers[header] = value.strip if header && value
    end
    if headers['Content-Type'] && headers['Content-Type'].include?('application/json')
      begin
        body = JSON.parse(body) unless body.nil? || body.strip.empty?
      rescue JSON::ParserError
        return { error: 'Invalid JSON format' }
      end
    end

    [method, path, headers, body]
  end

  def self.respond(client, status, message)
    client.puts "HTTP/1.1 #{status}"
    client.puts "Content-Type: application/json"
    client.puts
    client.puts message.is_a?(String) ? { message: message }.to_json : message.to_json
  end

  def self.not_found(client)
    respond(client, 404, { error: 'Not Found' })
  end
end
