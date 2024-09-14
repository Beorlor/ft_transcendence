require_relative '../config/database'
require_relative '../log/custom_logger'

module AuthRepository

  def self.register_user_42(user_info)
    Logger.log('AuthRepository', "Registering user42 with email #{user_info[:email]}")
    Database.insert_into_table('_user', user_info)
    Logger.log('AuthRepository', "User42 with email #{user_info[:email]} registered")
  end

  def self.get_user_by_email(email)
    Database.get_one_element_from_table('_user', 'email', email)
  end

  def self.get_user_by_id(id)
    Database.get_one_element_from_table('_user', 'id', id)
  end

  def self.register(user_info)
    Logger.log('AuthRepository', "Registering user with email #{user_info[:email]}")
    Database.insert_into_table('_user', user_info)
    Logger.log('AuthRepository', "User with email #{user_info[:email]} registered")
  end

end