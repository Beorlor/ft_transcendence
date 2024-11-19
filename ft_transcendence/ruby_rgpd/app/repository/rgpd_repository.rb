require_relative '../config/database'
require_relative '../log/custom_logger'

class RGPDRepository
  def initialize(logger = Logger.new)
    @logger = logger
  end

  def get_user_by_id(user_id)
    @logger.log('RGPDRepository', "Fetching user with ID: #{user_id}")
    Database.get_one_element_from_table('_user', 'id', user_id).first
  end

  def update_user_restrict_status(user_id, status)
    @logger.log('RGPDRepository', "Updating restrict status for user ID: #{user_id} to #{status}")
    Database.update_table('_user', { restrict: status }, "id = #{user_id}")
  end
end
