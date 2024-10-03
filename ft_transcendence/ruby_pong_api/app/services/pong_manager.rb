require_relative '../repository/pong_repository'

class PongManager

  def initialize(logger = Logger.new, pong_repository = PongRepository.new)
    @logger = logger
  end

  def create_game(body)
    @logger.log('PongManager', "Creating game with body: #{body}")
  end

end
