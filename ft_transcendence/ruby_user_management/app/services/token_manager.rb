require 'jwt'
require 'json'
require_relative '../repository/user_repository'

class TokenManager
  SECRET_KEY = ENV['SECRET_KEY']

  def initialize(logger = Logger.new)
    @logger = logger
  end

  # Generate Access Token with 'state' and 'role' claims
  def generate_access_token(user_id, state, role)
    payload = {
      user_id: user_id,
      state: state,
      role: role,
      type: 'access',
      iat: Time.now.to_i,
      exp: Time.now.to_i + 3600  # 1 hour expiry
    }
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def generate_tokens(user_id, state, role)
    access_token = generate_access_token(user_id, state, role)
    refresh_token = generate_refresh_token(user_id) if state == true
    { access_token: access_token, refresh_token: refresh_token }
  end

  # Generate Refresh Token
  def generate_refresh_token(user_id)
    payload = {
      user_id: user_id,
      type: 'refresh',
      iat: Time.now.to_i,
      exp: Time.now.to_i + 604800  # 7 days expiry
    }
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  # Verify Access Token (state must be true)
  def verify_access_token(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(token)
    return nil unless payload && payload['type'] == 'access' && payload['state'] == true
    payload
  end

  # Verify Token for User Code (state can be false)
  def verify_token_user_code(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(token)
    @logger.log('TokenManager', "Payload: #{payload}")
    return nil unless payload && payload['type'] == 'access' && payload['state'] == false
    payload
  end

  # Verify Admin Token
  def verify_admin_token(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = verify_access_token(token)
    return nil unless payload && payload['role'] == 1  # Role 1 is admin
    payload
  end

  # Refresh Tokens
  def refresh_tokens(refresh_token)
    if refresh_token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(refresh_token)
    return nil unless payload && payload['type'] == 'refresh'
    user_id = payload['user_id']
    # Assume the user is already verified and has state true
    new_access_token = generate_access_token(user_id, true, get_user_role(user_id))
    new_refresh_token = generate_refresh_token(user_id)
    { access_token: new_access_token, refresh_token: new_refresh_token }
  end

  def get_user_id(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(token)
    user_id = payload['user_id']
    return user_id
  end

  private

  def decode(token)
    begin
      decoded = JWT.decode(token.split(' ').last, SECRET_KEY, true, { algorithm: 'HS256' })
      decoded[0]
    rescue JWT::ExpiredSignature
      @logger.log('TokenManager', 'Token has expired')
      nil
    rescue JWT::DecodeError => e
      @logger.log('TokenManager', "Token decode error: #{e.message}")
      nil
    end
  end

  def get_user_role(user_id)
    user = UserRepository.new.get_user_by_id(user_id).first
    user ? user['role'].to_i : 0  # Default to role 0 if user not found
  end
end
