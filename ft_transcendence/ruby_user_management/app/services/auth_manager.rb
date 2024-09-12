require_relative '../repository/auth_repository'
require_relative '../config/security'
require 'uri'
require 'net/http'
require 'json'

module AuthManager

  def self.registerUser42(user)
    Logger.log('AuthManager', "Registering user with email #{user['email']}")
    user = Database.get_one_element_from_table('_user', 'email', user['email'])
    if user.length > 0
      Logger.log('AuthRepository', "User with email #{user['email']} already exists in database go to login")
      # add redirection to code mail...
      return
    end
    user_info = {
      username: user['login'],
      email: user['email'],
      role: 0,
      login_type: 1,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    AuthRepository.registerUser42(user_info)
    # add redirection to code mail...
  end

  def self.register(body)
    Logger.log('AuthManager', "Registering new user")
    if body.nil? || body.empty?
      return {error: 'Invalid body'}
    end
    Logger.log('AuthManager', "Username: #{body['username']}")
    if body['username'].nil? || body['username'].size < 3 || body['username'].size > 12
      return {error: 'Invalid username'}
    end
    email_regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
    Logger.log('AuthManager', "Email: #{body['email']}")
    if body['email'].nil? || body['email'].size < 5 || body['email'].size > 320 || !body['email'].match(email_regex)
      return {error: 'Invalid email'}
    end
    if body['password'].nil? || body['password'].size < 6 || body['password'].size > 255
      return {error: 'Invalid password'}
    end
    if body['password'] != body['password_confirmation']
      return {error: 'Passwords do not match'}
    end
    if AuthRepository.get_user_by_email(body['email']).length > 0
      Logger.log('AuthManager', "Email already in use")
      return {error: 'Email already in use'}
    end
    user_info = {
      username: body['username'],
      email: body['email'],
      password: Security.secure_password(body['password']),
      role: 0,
      login_type: 0,
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    AuthRepository.register(user_info)
    # edit and add redirection to code mail...
    return {success: 'User registered'}
  end

  def self.login(body)
    Logger.log('AuthManager', "Logging in user")
    if body.nil? || body.empty?
      return {error: 'Invalid body'}
    end
    Logger.log('AuthManager', "Email: #{body['email']}")
    if body['email'].nil? || body['email'].empty?
      return {error: 'Email is required'}
    end
    if body['password'].nil? || body['password'].empty?
      return {error: 'Password is required'}
    end
    user = AuthRepository.get_user_by_email(body['email'])
    Logger.log('AuthManager', "User: #{user}")
    if user.length == 0
      return {error: 'User not found'}
    end
    if !Security.verify_password(body['password'], user[0]['password'])
      return {error: 'Invalid password'}
    end
    Logger.log('AuthManager', "User logged in with email: #{body['email']}")
    return {success: 'User logged in', user: user[0]}
  end

  def self.get_user_info(client, access_token)
    Logger.log('AuthManager', "Getting user info with access token: #{access_token}")
    uri = URI.parse("https://api.intra.42.fr/v2/me")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

  
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  
    if response.code == '200'
      Logger.log('AuthManager', "User info retrieved successfully")
      user_info = JSON.parse(response.body)
      return user_info
    else
      Logger.log('AuthManager', "Error while getting user info: #{response.message}")
      return nil
    end
  end

  def self.get_access_token(client, authorization_code)
    Logger.log('AuthManager', "Getting access token with authorization code: #{authorization_code}")
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
      Logger.log('AuthManager', "Access token retrieved successfully")
      response_body = JSON.parse(response.body)
      access_token = response_body['access_token']
      access_token
    else
      Logger.log('AuthManager', "Error while getting access token: #{response.message}")
      nil
    end
  end

end