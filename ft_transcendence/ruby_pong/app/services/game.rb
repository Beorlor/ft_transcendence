

class Game
  attr_accessor :client1, :client2, :score, :status

  def initialize(client1, client2)
    @client1 = client1
    @client2 = client2
    @game_data = { client1_pts: 0, client2_pts: 0, ball_x: 0, ball_y: 0, ball_speed: 0, paddle1_y: 0, paddle2_y: 0 , paddle1_x: 0, paddle2_x: 0 }
    @start_time = Time.now
    @game = true
  end

  def recieve_message(client, message)
    @logger.log('Debug', "Recieved message: #{message}")
  end

  def send_game_data
    send_to_client(@client1, @game_data.to_json)
    send_to_client(@client2, @game_data.to_json)
  end
  
  def start
    start_timer(60)
    @client1[:ws].send('game started')
    @client2[:ws].send('game started')
    EM.add_periodic_timer(0.1) { send_game_data }
  end

  def send_to_client(client, message)
    client[:ws].send(message)
  end

  def end_game(message)
    send_to_client(@client1, message)
    send_to_client(@client2, message)
    @game = false
  end

  def start_timer(duration)
    EM.add_timer(duration) do
      end_game("Time's up! The game has ended.")
    end
  end

end
