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
        state: 3,
        rank_points: 0,
        updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      }
      @pong_repository.create_game_history(game_history)
      game_history[:user_id] = body['player2']
      @pong_repository.create_game_history(game_history)
    else
      @logger.log('PongManager', 'Error creating game')
      return { code: 500, message: 'Error creating game' }
    end
    @logger.log('PongManager', "Creating game with body: #{body}")
    { game_info: state, code: 200, message: 'Game created' }
  end

  def is_already_playing(user_id)
    game_info = @pong_repository.get_game_history(user_id)
    @logger.log('PongManager', "Checking if user is already playing with game_info: #{game_info}")
    if game_info
      if game_info[:state] == 3
        { game_info: game_info }
      else
        nil
      end
    else
      nil
    end
  end

  def update_player_history(body, game_id)
    game_history_player_1 = {
      rank_points: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    game_history_player_2 = {
      rank_points: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    if body['player1_pts'] > body['player2_pts']
      game_history_player_1[:state] = 1
      game_history_player_2[:state] = 0
    elsif body['player1_pts'] < body['player2_pts']
      game_history_player_1[:state] = 0
      game_history_player_2[:state] = 1
    else
      game_history_player_1[:state] = 2
      game_history_player_2[:state] = 2
    end

    @pong_repository.save_game_history(game_history_player_1, game_id, body['player1'])
    @pong_repository.save_game_history(game_history_player_2, game_id, body['player2'])
  end

  def end_game(body)
    @logger.log('PongManager', "Ending game with body: #{body}")
    game_info = @pong_repository.get_game(body['player1'])
    @logger.log('PongManager', "Ending game with game_info: #{game_info}")
    if game_info
      @logger.log('PongManager', "Ending game with body: #{body}")
      game_update = {
      player_1_score: body['player1_pts'],
      player_2_score: body['player2_pts'],
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
      @logger.log('PongManager', "Ending game with game_info: #{game_info}")
      @pong_repository.save_game(game_update, game_info['id'])
      @logger.log('PongManager', "Game ended with game_info: #{game_info}")
      update_player_history(body, game_info['id'])
      @logger.log('PongManager', "Game ended with body: #{body}")
      { code: 200, message: 'Game ended' }
    else
      { code: 500, message: 'Error ending game' }
    end
  end

end
