require_relative '../log/custom_logger'
require 'json'

class Game
  attr_accessor :client1, :client2, :game_data, :start_time, :game, :game_timer, :victory_points, :width, :height

  def initialize(client1, client2, game_id, victory_points = 5, width = 800, height = 600, pong_api = PongApi.new, logger = Logger.new)
    @client1 = client1
    @client2 = client2
    @game_data = { client1_pts: 0, client2_pts: 0,
    victory_points: victory_points, ball_radius: 8,
    width: width, height: height,
    bar_width: 12, bar_height: 120,
    ball_moove_speed: 20, ball_max_speed: 90,
    ball_accceleration: 2, game_id: game_id,
    ball_x: width / 2, ball_y: height / 2,
    ball_speed: 0, paddle1_y: height / 2 - 120 / 2,
    paddle2_y: height / 2 - 120 / 2 , paddle1_x: 20 ,
    player1_direction: 0, player2_direction: 0,
    paddle2_x: width - 20 - 12, delta_time: 0.016 }
    @start_time = Time.now
    @game = true
    @pong_api = pong_api
    @logger = logger
  end

  def reconnection(client)
    if client[:player]["id"] == @client1[:player]["id"]
      @client1 = client
    elsif client[:player]["id"] == @client2[:player]["id"]
      @client2 = client
    end
  end

  def receive_message(client, message)
    begin
      message = JSON.parse(message)
      @logger.log("Game", "receive_message: #{message["direction"]} with id #{client[:player]["id"]}")
      if client[:player]["id"] == @client1[:player]["id"]
        @game_data[:player1_direction] = message["direction"] == "up" ? -1 : (message["direction"] == "down" ? 1 : 0)
      elsif client[:player]["id"] == @client2[:player]["id"]
        @game_data[:player2_direction] = message["direction"] == "up" ? -1 : (message["direction"] == "down" ? 1 : 0)
      end
    rescue => e
      @logger.log("Game", "Error parsing message: #{e}")
      send_to_client(client, "Error parsing message")
      return
    end
  end

  def game_loop
    @game_data[:paddle1_y] += @game_data[:player1_direction] * 10 * @game_data[:delta_time]
    @game_data[:paddle2_y] += @game_data[:player2_direction] * 10 * @game_data[:delta_time]
    sended_data = { client1_pts: @game_data[:client1_pts], client2_pts: @game_data[:client2_pts], ball_x: @game_data[:ball_x], ball_y: @game_data[:ball_y],
    paddle1_y: @game_data[:paddle1_y], paddle2_y: @game_data[:paddle2_y], paddle1_x: @game_data[:paddle1_x], paddle2_x: @game_data[:paddle2_x], width: @game_data[:width], height: @game_data[:height] }
    send_to_client(@client1, sended_data.to_json)
    send_to_client(@client2, sended_data.to_json)
  end

  def start
    start_timer(60)
    send_to_client(@client1, "start")
    send_to_client(@client2, "start")
    @game_timer = EM.add_periodic_timer(@game_data[:delta_time]) { game_loop }
  end

  def send_to_client(client, message)
    client[:ws].send(message)
  end

  def end_game(message)
    send_to_client(@client1, message)
    send_to_client(@client2, message)
    @game = false
    stop_game_timer
    @pong_api.end_game('http://ruby_pong_api:4571/api/pong/end_game', @client1[:player]["id"], @client2[:player]["id"], @game_data[:client1_pts], @game_data[:client2_pts], @game_data[:game_id]) do |status|
      if status
        puts "Game ended with status: #{status}"
        @client1[:ws].close_connection
        @client2[:ws].close_connection
      else
        puts "Error ending game"
      end
    end
  end

  def start_timer(duration)
    EM.add_timer(duration) do
      end_game({end: "Time's up! The game has ended."}.to_json)
    end
  end

  def stop_game_timer
    @game_timer.cancel if @game_timer
  end
end
