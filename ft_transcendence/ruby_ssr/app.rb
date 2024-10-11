require 'webrick'
require 'erb'
require 'ostruct'
require 'json'
require 'net/http'
require_relative 'app/log/custom_logger'

mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
mime_types['js'] = 'application/javascript'
mime_types['mjs'] = 'application/javascript'
server = WEBrick::HTTPServer.new(:Port => 4568, :MimeTypes => mime_types)
logger = Logger.new

def user_logged(jwt, logger)
	uri = URI('http://ruby_user_management:4567/api/auth/verify-token-user')
	req = Net::HTTP::Get.new(uri)
	req['Cookie'] = "access_token=#{jwt}"
	http = Net::HTTP.new(uri.host, uri.port)
	res = http.start do |http|
		http.request(req)
	end
	logger.log('App', "Response from /api/auth/verify-token-user: #{res.body}")
  if res.is_a?(Net::HTTPSuccess)
		logger.log('App', "User logged #{JSON.parse(res.body)}.")
		return true
  else
		logger.log('App', "Failed to verify token: #{res.code} #{res.message}")
    return false
  end
end

def get_user_info(api_url, jwt)
  uri = URI(api_url)
	req = Net::HTTP::Get.new(uri)
	req['Cookie'] = "access_token=#{jwt}"
	http = Net::HTTP.new(uri.host, uri.port)
	res = http.start do |http|
		http.request(req)
	end
  if res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)["user"].first
  else
    nil
  end
end

def get_users_paginated(page)
  uri = URI("http://ruby_user_management:4567/api/users/#{page}")
  req = Net::HTTP::Get.new(uri)
  http = Net::HTTP.new(uri.host, uri.port)
  res = http.start do |http|
    http.request(req)
  end
  if res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  else
    nil
  end
end

def get_access_token(req)
	access_token = req.cookies.find { |cookie| cookie.name == 'access_token' }
	if access_token
		access_token = access_token.value
	else
		access_token = nil
	end
	access_token
end

def generate_navigation
  ERB.new(File.read("app/view/layouts/nav.erb")).result(binding)
end

def generate_response(req, res, logger)
  if req['X-Requested-With'] == 'XMLHttpRequest'
    json = { body: @pRes }
    logger.log('App', "Request IsLogged: #{req['IsLogged']}")
    if (@user_logged && req['IsLogged'] == 'false') || (!@user_logged && req['IsLogged'] == 'true')
      json[:nav] = @nav
    end
    res.content_type = "application/json"
    res.body = json.to_json
  else
    template = ERB.new(File.read("app/view/index.erb"))
    res.body = template.result(binding)
    res.content_type = "text/html"
  end
	@user_logged = nil
	@nav = nil
	@pRes = nil
end

def handle_route(req, res, logger, template_path)
  access_token = get_access_token(req)
  logger.log('App', "Request received with access token: #{access_token}")
  
  @user_logged = user_logged(access_token, logger)
  @nav = generate_navigation
  
  page = ERB.new(File.read(template_path))
  @pRes = page.result(binding)

  generate_response(req, res, logger)
end

server.mount_proc '/' do |req, res|
	handle_route(req, res, logger, "app/view/default.erb")
end

server.mount_proc '/pong' do |req, res|
	handle_route(req, res, logger, "app/view/localpong.erb")
end

server.mount_proc '/register' do |req, res|
	handle_route(req, res, logger, "app/view/register.erb")
end

server.mount_proc '/login' do |req, res|
	handle_route(req, res, logger, "app/view/login.erb")
end

server.mount_proc '/validate-code' do |req, res|
	handle_route(req, res, logger, "app/view/validate-code.erb")
end

server.mount_proc '/callback-tmp' do |req, res|
	handle_route(req, res, logger, "app/view/callback-tmp.erb")
end

server.mount_proc '/pongserv' do |req, res|
  handle_route(req, res, logger, "app/view/pongserv.erb")
end

server.mount_proc '/profile' do |req, res|
  @user_logged = user_logged(get_access_token(req), logger)
  access_token = get_access_token(req)
  @nav = generate_navigation

  if access_token
    user_info = get_user_info('http://ruby_user_management:4567/api/user/me', access_token)
    if user_info
      @username = user_info["username"]
      @email = user_info["email"]
      @img_url = user_info["img_url"]
      page = ERB.new(File.read("app/view/profile.erb"))
      @pRes = page.result(binding)
    else
      res.status = 500
      @pRes = "Erreur lors de la récupération des informations utilisateur."
    end
  else
    res.status = 401
    @pRes = "Utilisateur non authentifié."
  end

  generate_response(req, res, logger)
end

server.mount_proc '/edit-profile' do |req, res|
  @user_logged = user_logged(get_access_token(req), logger)
  access_token = get_access_token(req)
  @nav = generate_navigation

  if access_token
    user_info = get_user_info('http://ruby_user_management:4567/api/user/me', access_token)
    if user_info
      @user_info = user_info
      page = ERB.new(File.read("app/view/edit-profile.erb"))
      @pRes = page.result(binding)
    else
      res.status = 500
      @pRes = "Erreur lors de la récupération des informations utilisateur."
    end
  else
    res.status = 401
    @pRes = "Utilisateur non authentifié."
  end

  generate_response(req, res, logger)
end

server.mount_proc '/ranking' do |req, res|
  @user_logged = user_logged(get_access_token(req), logger)
  @current_page = req.path.match(/\/ranking\/(\d+)/)[1].to_i rescue 1
  users = get_users_paginated(@current_page)
  @nav = generate_navigation
  if users
    @users = users["users"]
    @nPages = users["nPages"].to_i + 1
    page = ERB.new(File.read("app/view/ranking.erb"))
    @pRes = page.result(binding)
  else
    res.status = 500
    @pRes = "Erreur lors de la récupération des utilisateurs."
  end

  generate_response(req, res, logger)
end

server.mount '/static', WEBrick::HTTPServlet::FileHandler, './static'
server.mount '/assets', WEBrick::HTTPServlet::FileHandler, './assets'

trap 'INT' do server.shutdown end
server.start
