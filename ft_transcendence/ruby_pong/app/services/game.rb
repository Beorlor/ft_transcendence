

class Game
  attr_accessor :client1, :client2, :game_data, :start_time, :game, :game_timer, :victory_points, :width, :height

  def initialize(client1, client2, victory_points = 5, width = 800, height = 600, pong_api = PongApi.new)
    @client1 = client1
    @client2 = client2

    @game_data = { client1_pts: 0, client2_pts: 0,
    victory_points: victory_points, ball_radius: 8,
    width: width, height: height,
    bar_width: 12, bar_height: 120,
    ball_moove_speed: 20, ball_max_speed: 90,
    ball_accceleration: 2,
    ball_x: 0, ball_y: 0,
    ball_speed: 0, paddle1_y: 0,
    paddle2_y: 0 , paddle1_x: 0,
    
    paddle2_x: 0 }
    @start_time = Time.now
    @game = true
    @pong_api = pong_api
  end

  def reconnection(client)
    if client[:player][:id] == @client1[:player][:id]
      @client1 = client
    elsif client[:player][:id] == @client2[:player][:id]
      @client2 = client
    end
  end

  def receive_message(client, message)
    puts "receive_message: #{message}"
  end

  def send_game_data
    sended_data = { client1_pts: @game_data[:client1_pts], client2_pts: @game_data[:client2_pts], ball_x: @game_data[:ball_x], ball_y: @game_data[:ball_y], paddle1_y: @game_data[:paddle1_y], paddle2_y: @game_data[:paddle2_y], paddle1_x: @game_data[:paddle1_x], paddle2_x: @game_data[:paddle2_x] }
    send_to_client(@client1, sended_data.to_json)
    send_to_client(@client2, sended_data.to_json)
  end

  def start
    start_timer(60)
    @client1[:ws].send('game started')
    @client2[:ws].send('game started')
    @game_timer = EM.add_periodic_timer(0.1) { send_game_data }
  end

  def send_to_client(client, message)
    client[:ws].send(message)
  end

  def end_game(message)
    send_to_client(@client1, message)
    send_to_client(@client2, message)
    @game = false
    stop_game_timer
    @pong_api.end_game('http://ruby_pong_api:4571/api/pong/end_game', @client1[:player]["id"], @client2[:player]["id"], @game_data[:client1_pts], @game_data[:client2_pts]) do |status|
      if status
        puts "Game ended with status: #{status}"
      else
        puts "Error ending game"
      end
    end
  end

  def start_timer(duration)
    EM.add_timer(duration) do
      end_game("Time's up! The game has ended.")
    end
  end

  def stop_game_timer
    @game_timer.cancel if @game_timer
  end
end
