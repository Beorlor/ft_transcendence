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
      state: 3,
      rank_points: 0,
      player_1_score: 0,
      player_2_score: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    state = @pong_repository.create_game(game_info)
    @logger.log('PongManager', "Creating game with state: #{state}")
    { game_info: state, code: 200, message: 'Game created' }
  end

  def is_already_playing(user_id)
    game_info = @pong_repository.get_game_one_user(user_id)
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
    game_history_player_1 = @pong_repository.get_game_history(body['player1']);
    game_history_player_2 = @pong_repository.get_game_history(body['player2']);
    result_player1 = {
      nb_game: game_history_player_2["nb_game"].to_i + 1,
      nb_win: game_history_player_1["nb_win"].to_i,
      nb_lose: game_history_player_1["nb_lose"].to_i
    }
    result_player2 = {
      nb_game: game_history_player_2["nb_game"].to_i + 1,
      nb_win: game_history_player_2["nb_win"].to_i,
      nb_lose: game_history_player_2["nb_lose"].to_i
    }
    if body['player1_pts'] > body['player2_pts']
      result_player1[:nb_win] += 1
      result_player2[:nb_lose] += 1
    elsif body['player1_pts'] < body['player2_pts']
      result_player2[:nb_win] += 1
      result_player1[:nb_lose] += 1
    end

    @pong_repository.save_game_history(result_player1, body['player1'])
    @pong_repository.save_game_history(result_player2, body['player2'])
  end

  def end_game(body)
    game_update = {
      player_1_score: body['player1_pts'],
      player_2_score: body['player2_pts'],
      state: 2,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    @pong_repository.save_game(game_update, body['game_id'])
    update_player_history(body, body['game_id'])
    { code: 200, message: 'Game ended' }
  end

end
