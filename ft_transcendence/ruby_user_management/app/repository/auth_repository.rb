require_relative '../config/database'

module AuthRepository

  def self.registerUser42(user_info)
    Database.insert_into_table('_user', user_info)
  end

end