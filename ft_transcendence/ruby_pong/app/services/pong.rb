require_relative '../log/custom_logger'
require_relative 'external/user_api'
require_relative 'external/pong_api'
require_relative 'game'

class Pong

  def initialize(logger = Logger.new, user_api = UserApi.new, pong_api = PongApi.new)
    @logger = logger
    @user_api = user_api
    @pong_api = pong_api
    @users_matchmaking_normal = []
    @users_matchmaking_ranked = []
    @games = {}
  end

  def create_game(client1, client2, ranked = false)
    @pong_api.create_game('http://ruby_pong_api:4571/api/pong/create_game', client1[:player]["id"], client2[:player]["id"], ranked) do |status|
      if status
        game = Game.new(client1, client2, status["game_info"]["id"], ranked)
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
    game = @games[game_info["id"]]
	if game == nil
		return nil
	end
    game.reconnection(client)
    client[:ws].onmessage do |message|
      game.receive_message(client, message)
    end
    client[:ws].send({ reco: 'reconnected to game' }.to_json)
  end

  def matchmaking(client, cookie, ranked = false)
    @logger.log("Matchmaking", "debut matchmaking")
    @user_api.user_logged(cookie['access_token']) do |logged|
      @user_api.get_user_info("http://ruby_user_management:4567/api/user/#{logged["user_id"]}") do |player|
        @logger.log("Matchmaking", player)
        if player.nil?
          @logger.log('Pong', "Error getting player info")
          next
        end
        @pong_api.get_game_history('http://ruby_pong_api:4571/api/pong/get_game_history', player['id']) do |game_data|
          if game_data
            reconnection_game({ ws: client, player: player }, game_data["game_info"])
            next
          end
          if ranked
            @users_matchmaking_ranked.push({
              ws: client,
              player: player
            })
            if @users_matchmaking_ranked.size == 2
              create_game(@users_matchmaking_ranked.shift, @users_matchmaking_ranked.shift, true)
            end
          else
            @users_matchmaking_normal.push({
            ws: client,
            player: player
            })
            if @users_matchmaking_normal.size == 2
              create_game(@users_matchmaking_normal.shift, @users_matchmaking_normal.shift)
            end
          end
        end
      end
		end
	end
end