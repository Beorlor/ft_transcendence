require 'jwt'
require 'json'

module TokenManager
  SECRET_KEY = ENV['SECRET_KEY']

  def self.generate_tokens(user_data)
    id_token = encode({ user_id: 1 }, exp: 3600)
    access_token = encode({ user_id: 1 }, exp: 600)
    refresh_token = encode({ user_id: 1 }, exp: 604800)

    { id_token: id_token, access_token: access_token, refresh_token: refresh_token }
  end

  def self.verify_access_token(token)
    decode(token)
  end

  def self.refresh_access_token(refresh_token)
    decoded_token = decode(refresh_token)
    if decoded_token
      encode({ user_id: decoded_token['user_id'] }, exp: 600)
    else
      nil
    end
  end

  private

  def self.encode(payload, exp: 3600)
    payload[:exp] = Time.now.to_i + exp
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
	begin
	  decoded = JWT.decode(token.split(' ').last, SECRET_KEY, true, { algorithm: 'HS256' })
	  decoded[0]
	rescue JWT::ExpiredSignature
	  nil  # Or raise an appropriate exception or return a specific error message
	rescue JWT::DecodeError
	  nil
	end
  end
end
