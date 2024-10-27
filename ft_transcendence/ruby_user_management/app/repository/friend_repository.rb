require_relative '../config/database'
require_relative '../log/custom_logger'

class FriendRepository

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def add_friend(user_id, friend_id)
    Database.insert_into_table('_friend', {user_id: user_id, friend_id: friend_id})
  end

end