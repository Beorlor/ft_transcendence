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
	template = ERB.new(File.read("app/view/localpong.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

server.mount_proc '/ssr/register' do |req, res|
	template = ERB.new(File.read("app/view/register.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

server.mount_proc '/ssr/login' do |req, res|
	template = ERB.new(File.read("app/view/login.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

server.mount '/static', WEBrick::HTTPServlet::FileHandler, './static'

trap 'INT' do server.shutdown end
server.start
