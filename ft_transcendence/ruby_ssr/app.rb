require 'webrick'
require 'erb'

server = WEBrick::HTTPServer.new(:Port => 4568)

server.mount_proc '/' do |req, res|
	@title = "Test Ruby"
	@current_time = Time.now
	template = ERB.new(File.read("view/index.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

server.mount_proc '/game' do |req, res|
	@title = "Game Ruby"
	@current_time = Time.now
	template = ERB.new(File.read("view/index.erb"))
	res.body = template.result(binding)
	res.content_type = "text/html"
end

trap 'INT' do server.shutdown end
server.start