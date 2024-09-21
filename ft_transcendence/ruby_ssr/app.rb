require 'webrick'
require 'erb'
require 'ostruct'
require 'json'
require_relative 'app/log/custom_logger'

mime_types = WEBrick::HTTPUtils::DefaultMimeTypes
mime_types['js'] = 'application/javascript'
mime_types['mjs'] = 'application/javascript'
server = WEBrick::HTTPServer.new(:Port => 4568, :MimeTypes => mime_types)

server.mount_proc '/' do |req, res|
	template = ERB.new(File.read("app/view/index.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

server.mount_proc '/pong' do |req, res|
	page = ERB.new(File.read("app/view/localpong.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		res.body = @pRes
	else
		template = ERB.new(File.read("app/view/index.erb"))
		res.body = template.result(binding)
	end
	res.content_type = "text/html"
	@pRes = ''
end

server.mount_proc '/ssr/register' do |req, res|
	page = ERB.new(File.read("app/view/register.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		res.body = @pRes
	else
		template = ERB.new(File.read("app/view/index.erb"))
		res.body = template.result(binding)
	end
	res.content_type = "text/html"
	@pRes = ''
end

server.mount_proc '/ssr/login' do |req, res|
	page = ERB.new(File.read("app/view/login.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		res.body = @pRes
	else
		template = ERB.new(File.read("app/view/index.erb"))
		res.body = template.result(binding)
	end
	res.content_type = "text/html"
	@pRes = ''
end

server.mount_proc '/validate-code' do |req, res|
	page = ERB.new(File.read("app/view/validate-code.erb"))
	@pRes = page.result(binding)
	if req['X-Requested-With'] == 'XMLHttpRequest'
		res.body = @pRes
	else
		template = ERB.new(File.read("app/view/index.erb"))
		res.body = template.result(binding)
	end
	res.content_type = "text/html"
	@pRes = ''
end

server.mount '/static', WEBrick::HTTPServlet::FileHandler, './static'
server.mount '/assets', WEBrick::HTTPServlet::FileHandler, './assets'

trap 'INT' do server.shutdown end
server.start
