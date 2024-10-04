require_relative '../repository/pong_repository'

class PongManager

  def initialize(logger = Logger.new, pong_repository = PongRepository.new)
    @logger = logger
    @pong_repository = pong_repository
  end

  def create_game(body)
    game_info = {
      player_1_id: body['player1'],
      player_2_id: body['player2'],
      ball_position: { x: 0, y: 0 }.to_json,
      position_player_1: { x: 0, y: 0 }.to_json,
      position_player_2: { x: 0, y: 0 }.to_json,
      player_1_score: 0,
      player_2_score: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    state = @pong_repository.create_game(game_info)
    @logger.log('PongManager', "Creating game with state: #{state}")
    if state  
      game_history = {
        user_id: body['player1'],
        game_id: state["id"],
        state: 2,
        rank_points: 0,
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      }
      @pong_repository.save_game_history(game_history)
      game_history[:user_id] = body['player2']
      @pong_repository.save_game_history(game_history)
    else
      @logger.log('PongManager', 'Error creating game')
      return { code: 500, message: 'Error creating game' }
    end
    @logger.log('PongManager', "Creating game with body: #{body}")
    { game_info: state, code: 200, message: 'Game created' }
  end

  def is_already_playing(user_id)
    game_info = @pong_repository.get_game_history(user_id)
    if game_info
      { game_info: game_info }
    else
      nil
    end
  end

end
