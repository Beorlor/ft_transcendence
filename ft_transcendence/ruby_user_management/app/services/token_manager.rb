require 'jwt'
require 'json'
require_relative '../repository/user_repository'

class TokenManager
  SECRET_KEY = ENV['SECRET_KEY']

  def initialize(logger = CustomLogger.new)
    @logger = logger
  end

  def generate_access_token(user_id, state, role)
    payload = {
      user_id: user_id,
      state: state,
      role: role,
      type: 'access',
      iat: Time.now.to_i,
      exp: Time.now.to_i + 3600
    }
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def generate_tokens(user_id, state, role)
    access_token = generate_access_token(user_id, state, role)
    refresh_token = generate_refresh_token(user_id) if state == true
    { access_token: access_token, refresh_token: refresh_token }
  end

  def generate_refresh_token(user_id)
    payload = {
      user_id: user_id,
      type: 'refresh',
      iat: Time.now.to_i,
      exp: Time.now.to_i + 3600 * 24 * 7
    }
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def verify_access_token(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(token)
    if !payload || payload['type'] != 'access' || payload['state'] != true
      return nil
    end
    payload
  end

  def verify_token_user_code(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(token)
    @logger.log('TokenManager', "Payload: #{payload}")
    if !payload || payload['type'] != 'access' || payload['state'] != false
      return nil
    end
    payload
  end

  def verify_admin_token(token)
    if token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = verify_access_token(token)
    if !payload || payload['role'] != 1
      return nil
    end
    payload
  end

  def refresh_tokens(refresh_token)
    if refresh_token.nil?
      @logger.log('TokenManager', 'Token is nil')
      return nil
    end
    payload = decode(refresh_token)
    if !payload || payload['type'] != 'refresh'
      return nil
    end
    user_id = payload['user_id']
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
    user ? user['role'].to_i : 0
  end
end
