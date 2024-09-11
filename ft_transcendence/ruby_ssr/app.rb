require 'webrick'
require 'erb'
require 'ostruct'
require 'json'
require_relative 'app/log/custom_logger'

server = WEBrick::HTTPServer.new(:Port => 4568)

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

server.mount_proc '/aipong' do |req, res|
	template = ERB.new(File.read("app/view/aipong.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

server.mount '/static', WEBrick::HTTPServlet::FileHandler, './static'

trap 'INT' do server.shutdown end
server.start