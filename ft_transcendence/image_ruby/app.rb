require 'webrick'
require 'mongo'
require_relative 'app/log/custom_logger'

logger = Logger.new
logger.log('Server', 'Starting server')

client = Mongo::Client.new([ 'localhost:27017' ], :database => 'ft_transcendence_db', user: 'user', password: 'password')
logger.log('Mongo', 'Connected to database')

server = WEBrick::HTTPServer.new(:Port => 4572)

server.mount_proc '/' do |req, res|
  logger.log('Server', "Request for #{req.path}")
  res.body = 'Hello, world ! /'
end

server.mount_proc '/img' do |req, res|
  logger.log('Server', "Request for #{req.path}")
  res.body = 'test'
end

server.mount_proc '/img/test' do |req, res|
  logger.log('Server', "Request for #{req.path}")
  res.body = 'test 2'
end

trap('INT') { server.shutdown }
server.start
