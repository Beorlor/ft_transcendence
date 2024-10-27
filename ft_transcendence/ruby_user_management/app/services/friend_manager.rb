require_relative '../repository/friend_repository'
require_relative '../repository/user_repository'
require_relative '../log/custom_logger'
require 'securerandom'
require 'uri'
require 'net/http'
require 'json'

class FriendManager

  def initialize(friend_repository = FriendRepository.new, user_repository = UserRepository.new, logger = Logger.new)
    @friend_repository = friend_repository
    @logger = logger
    @user_repository = user_repository
  end

  def add_friend(user_id, body)
    if body['friend_id'].nil? || body['friend_id'].to_i < 1
      @logger.log('FriendManager', "Invalid friend ID: #{body['friend_id']}")
      return {code: 400, error: 'Invalid friend ID' }
    end
    friend_id = body['friend_id']
    if user_id == friend_id
      @logger.log('FriendManager', "Cannot add yourself as a friend")
      return {code: 400, error: 'Cannot add yourself as a friend' }
    end
    if @user_repository.user_exists(friend_id)
      @logger.log('FriendManager', "Friend does not exist")
      return {code: 400, error: 'Friend does not exist' }
    end
    if @friend_repository.friend_exists(user_id, friend_id)
      @logger.log('FriendManager', "Friendship already exists")
      return {code: 400, error: 'Friendship already exists' }
    end
    @friend_repository.add_friend(user_id, friend_id)
    @logger.log('FriendManager', "Friend added")
    return {code: 200, success: 'Friend added' }
  end

end