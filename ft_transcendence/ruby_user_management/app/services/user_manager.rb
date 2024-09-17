require_relative '../repository/user_repository'
require_relative '../log/custom_logger'
require 'securerandom'
require 'uri'
require 'net/http'
require 'json'

class UserManager

  def initialize(user_repository = UserRepository.new, logger = Logger.new)
    @user_repository = user_repository
    @logger = logger
  end

  def get_user(user_id)
    if (user_id.to_i < 1)
      @logger.log('UserManager', "Invalid user ID: #{user_id}")
      return {code: 401, error: 'Invalid user ID' }
    end
    user = @user_repository.get_user_by_id(user_id)
    if user.length == 0
      @logger.log('UserManager', "User not found: #{user_id}")
      return {code: 404, error: 'User not found' }
    end
    @logger.log('UserManager', "User found: #{user_id}")
    return {code: 200, user: user}
  end
end