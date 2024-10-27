require_relative '../config/database'
require_relative '../log/custom_logger'

class FriendRepository

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def friend_exists(user_id, friend_id)
    @logger.info("Checking if friend exists with user_id: #{user_id} and friend_id: #{friend_id}")
    Database.get_one_element_from_table('_friendship', {requester_id: user_id, receiver_id: friend_id}).any?
  end

  def add_friend(user_id, friend_id)
    @logger.info("Adding friend with user_id: #{user_id} and friend_id: #{friend_id}")
    Database.insert_into_table('_friendship', {requester_id: user_id, receiver_id: friend_id})
    @logger.info("Friend added successfully")
  end

end