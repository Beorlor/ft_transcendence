require_relative '../log/custom_logger'
require_relative 'external/user_api'
require_relative 'external/pong_api'
require_relative 'game'

class Pong

  def initialize(logger = Logger.new, user_api = UserApi.new, pong_api = PongApi.new)
    @logger = logger
    @user_api = user_api
    @pong_api = pong_api
    @users = []
    @games = {}
  end

  def create_game(client1, client2)
    @logger.log('Pong', "Creating game with players: #{client1} and #{client2}")
    status = @pong_api.create_game('http://ruby_pong_api:4571/api/pong/create_game', client1[:player]['id'], client2[:player]['id'])
    @logger.log('Pong', "Creating game with status: #{status}")
    if !status["success"]
      @logger.log('Pong', "Error creating game: #{status[:error]}")
      return
    end
    game = Game.new(client1, client2)
    @games[status["game_info"]["id"]] = game
  end

  def matchmaking_normal(client, cookie)
    player = @user_api.get_user_info('http://ruby_user_management:4567/api/user/me', cookie['access_token'])
    @logger.log('Pong', "Matchmaking normal for player: #{player}")
    @users.push({
      ws: client,
      player: player
    })
    if @users.size == 2
      create_game(@users.shift, @users.shift)
    end
  end
end