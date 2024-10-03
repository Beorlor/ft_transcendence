require_relative '../log/custom_logger'
require_relative 'external/user_api'
require_relative 'external/pong_api'

class Pong

  def initialize(logger = Logger.new, user_api = UserApi.new, pong_api = PongApi.new)
    @logger = logger
    @user_api = user_api
    @pong_api = pong_api
    @users = []
  end

  def create_game(client1, client2)
    player1 = @user_api.get_user_info('http://ruby_user_management:4567/api/user/me', client1[:token])
    player2 = @user_api.get_user_info('http://ruby_user_management:4567/api/user/me', client2[:token])
    @logger.log('Pong', "Creating game with players: #{player1['username']} and #{player2['username']}")
    status = @pong_api.create_game('http://ruby_pong_api:4571/api/pong/create_game', player1['id'], player2['id'])
    client1[:ws].send('game created you are player 1')
    client2[:ws].send('game created you are player 2')
  end

  def matchmaking_normal(client, cookie)
    @users.push({
      ws: client,
      token: cookie['access_token']
    })
    if @users.size == 2
      create_game(@users.shift, @users.shift)
    end
  end
end