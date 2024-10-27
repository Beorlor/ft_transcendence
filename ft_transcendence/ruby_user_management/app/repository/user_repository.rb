require_relative '../config/database'
require_relative '../log/custom_logger'

class UserRepository

  def initialize(logger = Logger.new)
    @logger = logger
  end

  def register_complement_info(history)
    @logger.log('AuthRepository', "Registering complement info")
    Database.insert_into_table('_pongHistory', history)
    @logger.log('AuthRepository', "Complement info for user registered")
  end

  def register_user_42(user_info)
    @logger.log('AuthRepository', "Registering user42 with email #{user_info[:email]}")
    Database.insert_into_table('_user', user_info)
    @logger.log('AuthRepository', "User42 with email #{user_info[:email]} registered")
  end

  def update_user(user_info, user_id)
    @logger.log('AuthRepository', "Updating user with email #{user_info[:email]}")
    Database.update_table('_user', user_info, "id = #{user_id}")
    @logger.log('AuthRepository', "User with email #{user_info[:email]} updated")
  end

  def get_user_by_email(email)
    Database.get_one_element_from_table('_user', {email: email })
  end

  def get_user_by_id(id)
    Database.get_one_element_from_table('_user', {id: id })
  end

  def register(user_info)
    @logger.log('AuthRepository', "Registering user with email #{user_info[:email]}")
    Database.insert_into_table('_user', user_info)
    @logger.log('AuthRepository', "User with email #{user_info[:email]} registered")
  end

  def get_paginated_users(page)
    Database.get_paginated_element_from_table('_user', page, 10)
  end

  def get_all_users()
    Database.get_all_from_table('_user')
  end

  def user_exists(user_id)
    @logger.log('AuthRepository', "Checking if user exists with id #{user_id}")
    Database.get_one_element_from_table('_user', {id: user_id }).empty?
  end

end