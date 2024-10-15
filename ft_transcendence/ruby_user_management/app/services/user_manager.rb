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

  def get_users_paginated(page)
    if (page.to_i < 1)
      @logger.log('UserManager', "Invalid page: #{page}")
      return {code: 401, error: 'Invalid page' }
    end
    users = @user_repository.get_paginated_users(page)
    if users.length == 0
      @logger.log('UserManager', "No users found on page: #{page}")
      return {code: 404, error: 'No users found' }
    end
    @logger.log('UserManager', "Users found on page: #{page}")
    nPages = @user_repository.get_all_users.length / 10
    return {code: 200, users: users, nPages: nPages}
  end

  def update_user(user_id, body)
    user = @user_repository.get_user_by_id(user_id).first
    update= {}
    @logger.log('AuthManager', "Updating profile with body: #{body}")
    if body.nil? || body.empty?
      return { code: 400, error: 'Invalid body' }
    end

    if !body['username'].nil? && body['username'].size > 3 && body['username'].size < 12
      update[:username] = body['username']
    end
    if !body['img_url'].nil?
      @logger.log('AuthManager', "Image URL: #{body['img_url']}")
    end
    if user['login_type'] == 0
      email_regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
      @logger.log('AuthManager', "Email: #{body['email']}")
      if !body['email'].nil? && body['email'].size > 5 && body['email'].size < 320 && body['email'].match(email_regex)
        update[:email] = body['email']
      end
      if !body['password'].nil? && body['password'].size > 6 && body['password'].size < 255
        update[:password] = @security.secure_password(body['password'])
      end
    end
    if update.empty?
      return { code: 400, error: 'No valid parameters to update' }
    end

    @user_repository.update_user(update, user_id)
    return { code: 200, success: 'Profile updated' }
  end

end