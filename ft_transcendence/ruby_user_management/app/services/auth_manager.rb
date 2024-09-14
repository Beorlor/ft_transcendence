require_relative '../repository/auth_repository'
require_relative '../log/custom_logger'
require_relative '../services/validation_manager'
require_relative '../config/security'
require 'securerandom'
require 'uri'
require 'net/http'
require 'json'

class AuthManager

  def initialize(auth_repository = AuthRepository.new, logger = Logger.new, validation_manager = ValidationManager.new, security = Security.new)
    @auth_repository = auth_repository
    @logger = logger
    @validation_manager = validation_manager
    @security = security
  end

  def register_user_42(user)
    @logger.log('AuthManager', "Registering user with email #{user['email']}")
    user = Database.get_one_element_from_table('_user', 'email', user['email'])
    if user.length > 0
      @logger.log('AuthRepository', "User with email #{user['email']} already exists in database go to login")
      @validation_manager.generate_validation(user[0])
      return
    end
    user_info = {
      username: user['login'],
      email: user['email'],
      role: 0,
      login_type: 1,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    @auth_repository.register_user_42(user_info)
    user = Database.get_one_element_from_table('_user', 'email', user['email'])
    @validation_manager.generate_validation(user[0])
  end

  def register(body)
    @logger.log('AuthManager', "Registering new user")
    if body.nil? || body.empty?
      return {error: 'Invalid body'}
    end
    @logger.log('AuthManager', "Username: #{body['username']}")
    if body['username'].nil? || body['username'].size < 3 || body['username'].size > 12
      return {error: 'Invalid username'}
    end
    email_regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    @logger.log('AuthManager', "Email: #{body['email']}")
    if body['email'].nil? || body['email'].size < 5 || body['email'].size > 320 || !body['email'].match(email_regex)
      return {error: 'Invalid email'}
    end
    if body['password'].nil? || body['password'].size < 6 || body['password'].size > 255
      return {error: 'Invalid password'}
    end
    if body['password'] != body['password_confirmation']
      return {error: 'Passwords do not match'}
    end
    if @auth_repository.get_user_by_email(body['email']).length > 0
      @logger.log('AuthManager', "Email already in use")
      return {error: 'Email already in use'}
    end
    user_info = {
      username: body['username'],
      email: body['email'],
      password: @security.secure_password(body['password']),
      role: 0,
      login_type: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    @auth_repository.register(user_info)
    user = @auth_repository.get_user_by_email(body['email'])
    @validation_manager.generate_validation(user[0])
    return {success: 'User registered'}
  end

  def login(body)
    @logger.log('AuthManager', "Logging in user")
    if body.nil? || body.empty?
      return {error: 'Invalid body'}
    end
    @logger.log('AuthManager', "Email: #{body['email']}")
    if body['email'].nil? || body['email'].empty?
      return {error: 'Email is required'}
    end
    if body['password'].nil? || body['password'].empty?
      return {error: 'Password is required'}
    end
    user = @auth_repository.get_user_by_email(body['email'])
    @logger.log('AuthManager', "User: #{user}")
    if user.length == 0
      return {error: 'User not found'}
    end
    if !@security.verify_password(body['password'], user[0]['password'])
      return {error: 'Invalid password'}
    end
    @validation_manager.generate_validation(user[0])
    return {success: 'User logged in', user: user[0]}
  end

  def valid_token(payload, body)
    @logger.log('AuthManager', "Validating email token id: #{payload['user_id']}")
    if payload['user_id'].nil? || payload['user_id'].empty?
      return {error: 'Invalid JwtToken'}
    end
    status = ValidationManager.validate(payload['user_id'], body['token'])
    if status[:error]
      return {error: status[:error]}
    end
    return {success: status[:success]}
  end

  def get_user_info(client, access_token)
    @logger.log('AuthManager', "Getting user info with access token: #{access_token}")
    uri = URI.parse("https://api.intra.42.fr/v2/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code == '200'
      @logger.log('AuthManager', "User info retrieved successfully")
      user_info = JSON.parse(response.body)
      return user_info
    else
      @logger.log('AuthManager', "Error while getting user info: #{response.message}")
      return nil
    end
  end

  def get_access_token(client, authorization_code)
    @logger.log('AuthManager', "Getting access token with authorization code: #{authorization_code}")
    uri = URI.parse("https://api.intra.42.fr/oauth/token")

    params = {
      grant_type: 'authorization_code',
      client_id: ENV['API_CLIENT'],
      client_secret: ENV['API_SECRET'],
      code: authorization_code,
      redirect_uri: 'http://localhost:8082/auth/callback'
    }
  
    response = Net::HTTP.post_form(uri, params)
  
    if response.is_a?(Net::HTTPSuccess)
      @logger.log('AuthManager', "Access token retrieved successfully")
      response_body = JSON.parse(response.body)
      access_token = response_body['access_token']
      access_token
    else
      @logger.log('AuthManager', "Error while getting access token: #{response.message}")
      nil
    end
  end

end