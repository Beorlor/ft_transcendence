require_relative '../repository/user_repository'
require_relative '../log/custom_logger'
require_relative '../services/validation_manager'
require_relative '../config/security'
require_relative '../services/token_manager'
require 'securerandom'
require 'uri'
require 'net/http'
require 'json'

class AuthManager

  def initialize(
    user_repository = UserRepository.new,
    logger = Logger.new,
    validation_manager = ValidationManager.new,
    security = Security.new,
    token_manager = TokenManager.new(logger)  # Injected TokenManager
  )
    @user_repository = user_repository
    @logger = logger
    @validation_manager = validation_manager
    @security = security
    @token_manager = token_manager  # Assigned TokenManager
  end

  # User registration via 42 OAuth
  def register_user_42(user)
    @logger.log('AuthManager', "Registering user with email #{user['email']}")
    user42 = @user_repository.get_user_by_email(user['email'])
    if user42.length > 0
      @logger.log('AuthManager', "User with email #{user['email']} already exists in database, proceeding to login")
      # Generate access token with state false
      access_token = @token_manager.generate_access_token(user42[0]['id'], false, user42[0]['role'])  # Changed
      @validation_manager.generate_validation(user42[0])
      return { code: 200, access_token: access_token }  # Return access token with state false
    end
    user_info = {
      username: user['login'],
      email: user['email'],
      role: 0,
      login_type: 1,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    @user_repository.register_user_42(user_info)
    user42 = @user_repository.get_user_by_email(user['email'])
    # Generate access token with state false
    access_token = @token_manager.generate_access_token(user42[0]['id'], false, user42[0]['role'])  # Changed
    @validation_manager.generate_validation(user42[0])
    return { code: 200, access_token: access_token }  # Return access token with state false
  end

  # User registration via classic method
  def register(body)
    @logger.log('AuthManager', "Registering new user")
    if body.nil? || body.empty?
      return { code: 400, error: 'Invalid body' }
    end
    @logger.log('AuthManager', "Username: #{body['username']}")
    if body['username'].nil? || body['username'].size < 3 || body['username'].size > 12
      return { code: 400, error: 'Invalid username' }
    end
    email_regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    @logger.log('AuthManager', "Email: #{body['email']}")
    if body['email'].nil? || body['email'].size < 5 || body['email'].size > 320 || !body['email'].match(email_regex)
      return { code: 400, error: 'Invalid email' }
    end
    if body['password'].nil? || body['password'].size < 6 || body['password'].size > 255
      return { code: 400, error: 'Invalid password' }
    end
    if body['password'] != body['password_confirmation']
      return { code: 400, error: 'Passwords do not match' }
    end
    if @user_repository.get_user_by_email(body['email']).length > 0
      @logger.log('AuthManager', "Email already in use")
      return { code: 400, error: 'Email already in use' }
    end
    user_info = {
      username: body['username'],
      email: body['email'],
      password: @security.secure_password(body['password']),
      role: 0,
      login_type: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    @user_repository.register(user_info)
    user = @user_repository.get_user_by_email(body['email'])
    # Generate access token with state false
    access_token = @token_manager.generate_access_token(user[0]['id'], false, user[0]['role'])  # Changed
    @validation_manager.generate_validation(user[0])
    return { code: 200, success: 'User registered', access_token: access_token }  # Return access token with state false
  end

  # User login
  def login(body)
    @logger.log('AuthManager', "Logging in user")
    if body.nil? || body.empty?
      return { code: 400, error: 'Invalid body' }
    end
    @logger.log('AuthManager', "Email: #{body['email']}")
    if body['email'].nil? || body['email'].empty?
      return { code: 400, error: 'Email is required' }
    end
    if body['password'].nil? || body['password'].empty?
      return { code: 400, error: 'Password is required' }
    end
    user = @user_repository.get_user_by_email(body['email'])
    @logger.log('AuthManager', "User: #{user}")
    if user.length == 0
      return { code: 404, error: 'User not found' }
    end
    unless @security.verify_password(body['password'], user[0]['password'])
      return { code: 401, error: 'Invalid password' }
    end
    # Generate access token with state false
    access_token = @token_manager.generate_access_token(user[0]['id'], false, user[0]['role'])  # Changed
    @validation_manager.generate_validation(user[0])
    return { code: 200, success: 'User logged in', access_token: access_token }  # Return access token with state false
  end

  # Validate the code entered by the user
  def validate_code(user_id, code)
    validation_result = @validation_manager.validate(user_id, code)
    return validation_result unless validation_result[:code] == 200

    # Generate new access token with state true and refresh token
    user = @user_repository.get_user_by_id(user_id).first
    new_access_token = @token_manager.generate_access_token(user_id, true, user['role'])  # Changed
    refresh_token = @token_manager.generate_refresh_token(user_id)

    { code: 200, success: "Token valid", access_token: new_access_token, refresh_token: refresh_token }  # Return new tokens
  end

  # Get user info from 42 API
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

  # Get access token from 42 API using authorization code
  def get_access_token(client, authorization_code)
    @logger.log('AuthManager', "Getting access token with authorization code: #{authorization_code}")
    uri = URI.parse("https://api.intra.42.fr/oauth/token")

    params = {
      grant_type: 'authorization_code',
      client_id: ENV['API_CLIENT'],
      client_secret: ENV['API_SECRET'],
      code: authorization_code,
      redirect_uri: 'https://localhost/callback-tmp'
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
