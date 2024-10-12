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
    @logger.log('Debug', "client1[:player]: #{client1[:player].inspect}")
    @logger.log('Debug', "client2[:player]: #{client2[:player].inspect}")
    @pong_api.create_game('http://ruby_pong_api:4571/api/pong/create_game', client1[:player]["id"], client2[:player]["id"]) do |status|
      if status
        @logger.log('Pong', "Creating game with status: #{status}")
        game = Game.new(client1, client2, status["game_info"]["id"])
        @games[status["game_info"]["id"]] = game

        game.start

        client1[:ws].onmessage do |message|
          game.receive_message(client1, message)
        end

        client2[:ws].onmessage do |message|
          game.receive_message(client2, message)
        end
        
      else
        @logger.log('Pong', "Error creating game")
      end
    end
  end

  def reconnection_game(client, game_info)
    @logger.log('Pong', "Reconnection game: #{game_info}")
    game = @games[game_info["id"]]
    @logger.log('Pong', "Reconnection game: #{game}")
    game.reconnection(client)
    client[:ws].onmessage do |message|
      game.receive_message(client, message)
    end
    client[:ws].send('reconnected to game')
  end

  def matchmaking_normal(client, cookie)
    @user_api.get_user_info('http://ruby_user_management:4567/api/user/me', cookie['access_token']) do |player|
      if player.nil?
        @logger.log('Pong', "Error getting player info")
        next
      end
      @pong_api.get_game_history('http://ruby_pong_api:4571/api/pong/get_game_history', player['id']) do |game_data|
        @logger.log('Pong', "Game data: #{game_data}")
        if game_data
          reconnection_game({ ws: client, player: player }, game_data["game_info"][0])
          @logger.log('Pong', "Game data: #{game_data}")
          next
        end
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
  end
end