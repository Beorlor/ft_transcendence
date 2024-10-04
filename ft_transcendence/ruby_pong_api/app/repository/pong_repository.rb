require_relative '../config/database'
require_relative '../log/custom_logger'

class PongRepository

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def save_game_history(game_info)
    Database.insert_into_table('_pongHistory', game_info)
  end

  def create_game(game_info)
    Database.insert_into_table('_pong', game_info)
  end

  def get_game_history(user_id)
    Database.get_one_element_from_table('_pongHistory', { user_id: user_id, state: 2 })
  end
end