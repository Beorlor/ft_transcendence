require_relative '../config/database'
require_relative '../log/custom_logger'

class PongRepository

  def initialize(logger = Logger.new)
    @logger = logger
  end

end