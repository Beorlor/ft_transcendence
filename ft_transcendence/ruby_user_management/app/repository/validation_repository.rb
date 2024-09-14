require_relative '../config/database'
require_relative '../log/custom_logger'

module ValidationRepository

  def self.register_validation(activation_info)
    Logger.log('AuthRepository', "Registering email activation for user with id #{activation_info[:user_id]}")
    Database.insert_into_table('_emailActivation', activation_info)
  end

  def self.update_validation(activation_info)
    Logger.log('AuthRepository', "Updating email activation for user with id #{activation_info[:user_id]}")
    Database.update_table('_emailActivation', activation_info)
  end

  def self.get_validation_by_user_id(user_id)
    Logger.log('AuthRepository', "Getting email activation for user with id #{user_id}")
    Database.get_one_element_from_table('_emailActivation', 'user_id', user_id)
  end

end