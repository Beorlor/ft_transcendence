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
	uri = URI('https://nginx/auth/verify-token-user')
	req = Net::HTTP::Get.new(uri)
	req['Authorization'] = jwt
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = (uri.scheme == 'https') # A suppriner en prod
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https' # A suppriner en prod
	res = http.start do |http|
		http.request(req)
	end
  if res.is_a?(Net::HTTPSuccess)
		logger.log('App', "User logged #{JSON.parse(res.body)}.")
		true
  else
    false
  end
end

server.mount_proc '/' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: ''}
		logger.log('App', "/ User logged: #{@user_logged}, IsLogged: #{req['IsLogged']}")
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
	@pRes = ''
end

server.mount_proc '/pong' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
	page = ERB.new(File.read("app/view/localpong.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: @pRes}
		logger.log('App', "Pong User logged: #{@user_logged}, IsLogged: #{req['IsLogged']}")
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
	@pRes = ''
end

server.mount_proc '/ssr/register' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
	page = ERB.new(File.read("app/view/register.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: @pRes}
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
	@pRes = ''
end

server.mount_proc '/ssr/login' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
	user_logged(req['Authorization'], logger)
	page = ERB.new(File.read("app/view/login.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: @pRes}
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
	@pRes = ''
end

server.mount_proc '/validate-code' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
	page = ERB.new(File.read("app/view/validate-code.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: @pRes}
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
	@pRes = ''
end

server.mount_proc '/callback-tmp' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
	page = ERB.new(File.read("app/view/callback-tmp.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: @pRes}
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
	@pRes = ''
end

def get_user_info(api_url, jwt)
  uri = URI(api_url)
	req = Net::HTTP::Get.new(uri)
	req['Authorization'] = jwt
	http = Net::HTTP.new(uri.host, uri.port)
	http.use_ssl = (uri.scheme == 'https') # A suppriner en prod
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https' # A suppriner en prod
	res = http.start do |http|
		http.request(req)
	end
  if res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  else
    nil
  end
end

server.mount_proc '/profil' do |req, res|
	@user_logged = user_logged(req['Authorization'], logger)
	navigation = ERB.new(File.read("app/view/layouts/nav.erb"))
	@nav = navigation.result(binding)
  jwt = req['Authorization']
  if jwt
    api_url = 'https://nginx/user/me'
    user_info = get_user_info(api_url, jwt)
    if user_info
			logger.log('App', "User info: #{user_info}")
      page = ERB.new(File.read("app/view/profil.erb"))
      @pRes = page.result(binding)
    else
      res.status = 500
      @pRes = "Erreur lors de la récupération des informations utilisateur."
    end
  else
    res.status = 401
    @pRes = "Utilisateur non authentifié."
  end
	if req['X-Requested-With'] == 'XMLHttpRequest'
		json = { body: @pRes}
		logger.log('App', "Profil User logged: #{@user_logged}, IsLogged: #{req['IsLogged']}")
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
	@pRes = ''
end

server.mount '/static', WEBrick::HTTPServlet::FileHandler, './static'
server.mount '/assets', WEBrick::HTTPServlet::FileHandler, './assets'

trap 'INT' do server.shutdown end
server.start
