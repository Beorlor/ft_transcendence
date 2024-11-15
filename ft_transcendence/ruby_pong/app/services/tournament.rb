require_relative '../log/custom_logger'
require_relative 'external/user_api'
require_relative 'external/pong_api'
require_relative 'game'

class Tournament

  def initialize(logger = Logger.new, user_api = UserApi.new, pong_api = PongApi.new)
    @logger = logger
    @user_api = user_api
    @pong_api = pong_api
    @tournaments = {}
  end

  def create_game(client1, client2, tournament_id, type)
    @pong_api.create_game('http://ruby_pong_api:4571/api/pong/create_game', client1[:player]["id"], client2[:player]["id"], type) do |status|
      if status
        game = Game.new(client1, client2, status["game_info"]["id"], ranked)
        @games[status["game_info"]["id"]] = game

        game.start

        game.on_game_end = lambda do |winner|
          if winner == false
            client1.close_connection
            client2.close_connection
          else
            if winner[:winner]
              client2[:ws].send({status: "Lose"}.to_json)
              @tournament[tournament_id][:players].each do |player|
                if player[:player]["id"] == client2[:player]["id"]
                  client2[:ws].close_connection
                  @tournament[tournament_id][:players].delete(player)
                  break
                end
              end
              client1[:ws].send({status: "Win"}.to_json)
              @tournament[tournament_id][client1[:player]["id"]][:opponent] = nil
              next_game_tournament(tournament_id)
            else
              client1[:ws].send({status: "Lose"}.to_json)
              @tournament[tournament_id][:players].each do |player|
                if player[:player]["id"] == client1[:player]["id"]
                  client1[:ws].close_connection
                  @tournament[tournament_id][:players].delete(player)
                  break
                end
              end
              client2[:ws].send({status: "Win"}.to_json)
              @tournament[tournament_id][client2[:player]["id"]][:opponent] = nil
              next_game_tournament(tournament_id)
            end
          end
        end

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

  def build_tournament(tournament_id)
    if @tournaments[tournament_id].length == 1
      @logger.log('Pong', "Tournament ended")
    end
    @tournaments[tournament_id][:players].each_with_index do |player, index|
      if index % 2 == 0
        if @tournaments[tournament_id][:players][index + 1] && @tournaments[tournament_id][:players][index + 1][:opponent].nil?
          player[:opponent] = @tournaments[tournament_id][:players][index + 1]
          create_game(player, player[:opponent], tournament_id, 3)
        elsif @tournaments[tournament_id][:players][index - 1] && @tournaments[tournament_id][:players][index - 1][:opponent].nil?
          player[:opponent] = @tournaments[tournament_id][:players][index - 1]
          create_game(player, player[:opponent], tournament_id, 3)
        else
          player[:ws].send({status: "Waiting"}.to_json)
        end
      end
    end
    if @tournaments[tournament_id][:players].length % 2 != 0
      @tournaments[tournament_id][:players][-1][:ws].send({status: "Waiting"}.to_json)
    end
    @tournaments[tournament_id][:players] = players
  end

  def start_tournament(tournament_id)
    @pong_api.start_tournament('http://ruby_pong_api:4571/api/pong/start_tournament', tournament_id) do |status|
      if status
        @tournaments[tournament_id][:tournament]["tournament"]["status"] = "started"
        @tournaments[tournament_id][:players].each do |player|
          player[:ws].send({status: "Started"}.to_json)
        end
        build_tournament(tournament_id)
      else
        @logger.log('Pong', "Error starting tournament")
      end
    end
  end

  def tournament(client, tournament_id, cookie)
    if @tournaments[tournament_id].nil?
      @pong_api.get_tournament('http://ruby_pong_api:4571/api/tournament', tournament_id) do |status|
        if status.nil?
          client.send({ error: "Invalid tournament" }.to_json)
          client.close
        else
          @tournaments[tournament_id] = { tournament: status, players: [], start_timer: nil }
          @user_api.user_logged(cookie['access_token']) do |logged|
            @user_api.get_user_info("http://ruby_user_management:4567/api/user/#{logged["user_id"]}") do |player|
              if player.nil?
                client.send({ error: "Invalid player" }.to_json)
                client.close
                @logger.log('Pong', "Error getting player info")
                next
              end
              player[:opponent] = nil
              @tournaments[tournament_id][:players].push({ player: player, ws: client })
              end_time = Time.strptime(@tournaments[tournament_id][:tournament]["tournament"]["start_at"], "%Y-%m-%d %H:%M:%S")
              @tournaments[tournament_id][:start_timer] = end_time
              current_time = Time.now
              delay = [end_time - current_time, 0].max
              if delay > 0
                EM.add_timer(delay) do
                  if @tournaments[tournament_id][:players].length >= 2
                    start_tournament(tournament_id)
                  else
                    @tournaments[tournament_id][:players].each do |player|
                      player[:ws].send({ end: "end" }.to_json)
                      player[:ws].close
                    end
                  end
                end
              end
              client.send({ status: "Waiting", time_end: @tournaments[tournament_id][:start_timer] }.to_json)
            end
          end
        end
      end
    else
      @user_api.user_logged(cookie['access_token']) do |logged|
        @user_api.get_user_info("http://ruby_user_management:4567/api/user/#{logged["user_id"]}") do |player|
          if player.nil?
            client.send({ error: "Invalid player" }.to_json)
            client.close
            @logger.log('Pong', "Error getting player info")
            next
          end
          @tournaments[tournament_id][:players].push({ player: player, ws: client })
          client.send({ status: "Waiting", time_end: @tournaments[tournament_id][:start_timer] }.to_json)
        end
      end
    end
  end  
end