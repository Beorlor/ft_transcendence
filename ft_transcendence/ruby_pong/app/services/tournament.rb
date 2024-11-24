require_relative '../log/custom_logger'
require_relative 'external/user_api'
require_relative 'external/pong_api'
require 'tzinfo'
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
        game = Game.new(client1, client2, status["game_info"]["id"], type)
        @tournaments[tournament_id][:games][status["game_info"]["id"]] = game

        game.start

        game.on_game_end = lambda do |winner|
          if winner == false
            client1[:ws].close
            client2[:ws].close
            @logger.log('Pong', "Game ended with status lll: #{winner}")
          else
            winner = JSON.parse(winner)
            @logger.log('Pong', "winner #{winner['winner']}")
            if winner['winner']
              client2[:ws].send({status: "Lose"}.to_json)
              @tournaments[tournament_id][:players].each do |player|
                if player[:player]["id"] == client2[:player]["id"]
                  client2[:ws].close
                  @tournaments[tournament_id][:players].delete(player)
                elsif player[:player]["id"] == client1[:player]["id"]
                  player[:opponent] = nil
                end
              end
              @logger.log('Pong', "winner cl1 #{winner}")
              client1[:ws].send({status: "Win"}.to_json)
              build_tournament(tournament_id)
            else
              @logger.log('Pong', "winner ttttt#{winner}")
              client1[:ws].send({status: "Lose"}.to_json)
              @tournaments[tournament_id][:players].each do |player|
                if player[:player]["id"] == client1[:player]["id"]
                  client1[:ws].close
                  @tournaments[tournament_id][:players].delete(player)
                elsif player[:player]["id"] == client2[:player]["id"]
                  player[:opponent] = nil
                end
              end
              @logger.log('Pong', "winner cl2 #{winner}")
              client2[:ws].send({status: "Win"}.to_json)
              build_tournament(tournament_id)
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
    @logger.log('Pong', "Building tournament")
    if @tournaments[tournament_id][:players].length == 1
      @tournaments[tournament_id][:players][0][:ws].send({status: "Win"}.to_json)
      @tournaments[tournament_id][:players][0][:ws].close
      @logger.log('Pong', "Tournament ended")
      return
    end
    @tournaments[tournament_id][:players].each_with_index do |player, index|
      @logger.log('Pong', "Checking player #{index}")
      if index % 2 == 0
        if @tournaments[tournament_id][:players][index + 1] && @tournaments[tournament_id][:players][index + 1][:opponent].nil?
          @logger.log('Pong', "Creating game +1")
          @tournaments[tournament_id][:players][index][:opponent] = @tournaments[tournament_id][:players][index + 1]
          @tournaments[tournament_id][:players][index + 1][:opponent] = @tournaments[tournament_id][:players][index]
          create_game(player, player[:opponent], tournament_id, 3)
        elsif @tournaments[tournament_id][:players][index - 1] && @tournaments[tournament_id][:players][index - 1][:opponent].nil?
          @logger.log('Pong', "Creating game -1")
          @tournaments[tournament_id][:players][index][:opponent] = @tournaments[tournament_id][:players][index - 1]
          @tournaments[tournament_id][:players][index - 1][:opponent] = @tournaments[tournament_id][:players][index]
          create_game(player, player[:opponent], tournament_id, 3)
        else
          @logger.log('Pong', "Waiting for opponent")
          tz = TZInfo::Timezone.get('Europe/Paris')
          player[:ws].send({status: "Waiting", time_end: (Time.now() + 1 * 60).strftime("%Y-%m-%d %H:%M:%S")}.to_json)
        end
      end
    end
  end

  def start_tournament(tournament_id, jwt)
    @pong_api.start_tournament('http://ruby_pong_api:4571/api/tournament/start', tournament_id, jwt) do |status|
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
          @tournaments[tournament_id] = { tournament: status, players: [], start_timer: nil, games: {} }
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
              tz = TZInfo::Timezone.get('Europe/Paris')
              @tournaments[tournament_id][:start_timer] = end_time
              current_time = Time.now
              delay = [end_time - current_time, 0].max
              client.send({ status: "Waiting", time_end: @tournaments[tournament_id][:start_timer] }.to_json)
              if delay > 0
                EM.add_timer(delay) do
                  if @tournaments[tournament_id][:players].length >= 2
                    start_tournament(tournament_id, cookie['access_token'])
                  else
                    @tournaments[tournament_id][:players].each do |player|
                      player[:ws].send({ end: "end" }.to_json)
                      #player[:ws].close
                    end
                  end
                end
              end
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