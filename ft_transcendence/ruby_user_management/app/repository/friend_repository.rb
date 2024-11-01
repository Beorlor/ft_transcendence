require_relative '../config/database'
require_relative '../log/custom_logger'

class FriendRepository

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def friend_exists(user_id, friend_id)
    @logger.log("FriendRepository", "Checking if friend exists with user_id: #{user_id} and friend_id: #{friend_id}")
    Database.get_one_element_from_table('_friendship', {}, {requester_id: user_id, receiver_id: friend_id}).any?
  end

  def add_friend(user_id, friend_id)
    @logger.log("FriendRepository", "Adding friend with user_id: #{user_id} and friend_id: #{friend_id}")
    Database.insert_into_table('_friendship', {requester_id: user_id, receiver_id: friend_id})
    @logger.log("FriendRepository", "Friend added successfully")
  end

  def get_friends(user_id)
    @logger.log("FriendRepository", "Getting friends for user_id: #{user_id}")
    Database.get_friendship_plus_information(user_id)
  end

end