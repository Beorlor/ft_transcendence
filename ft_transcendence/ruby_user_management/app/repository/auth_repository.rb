require_relative '../config/database'
require_relative '../log/custom_logger'

module AuthRepository

  def self.registerUser42(user_info)
    Logger.log('AuthRepository', "Registering user with email #{user_info[:email]}")
    user = Database.get_one_element_from_table('_user', 'email', user_info[:email])
    if user.length > 0
      Logger.log('AuthRepository', "User with email #{user_info[:email]} already exists")
      return
    end
    Database.insert_into_table('_user', user_info)
    Logger.log('AuthRepository', "User with email #{user_info[:email]} registered")
  end

end