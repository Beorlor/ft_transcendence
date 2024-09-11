require 'bcrypt'

class Security

  def self.secure_password(password)
    BCrypt::Password.create(password)
  end

  def self.verify_password(entered_password, stored_hashed_password)
    BCrypt::Password.new(stored_hashed_password) == entered_password
  end
  
end
