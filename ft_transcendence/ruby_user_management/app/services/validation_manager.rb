require_relative '../repository/validation_repository'
require_relative '../services/mail_manager'
require_relative '../config/security'
require 'securerandom'
require 'time'
require 'uri'
require 'net/http'
require 'json'

module ValidationManager
  def self.generate_validation(user)
    Logger.log('ValidationManager', "Generating validation for user with email #{user['email']}")
    code = SecureRandom.random_number(1_000_000).to_s.rjust(6, '0')
    Logger.log('ValidationManager', "Code generated: #{code}")
    activation_info = {
      user_id: user['id'],
      token: code,
      expire_at: (Time.now + 5 * 60).strftime("%Y-%m-%d %H:%M:%S"),
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    }
    validation = ValidationRepository.get_validation_by_user_id(user['id'])
    if validation.length > 0
      Logger.log('ValidationManager', "Validation already exists for user with email #{user['email']}")
      ValidationRepository.update_validation(activation_info)
      Logger.log('ValidationManager', "Validation updated")
    else
      ValidationRepository.register_validation(activation_info)
    end
    Logger.log('ValidationManager', "Sending email to user with email #{user['email']}")
    MailManager.instance.send_email(
      from: 'noreply@ft_transcendence.com',
      to: user['email'],
      subject: 'Validation code',
      body: "Your validation code is: #{code}"
    )
    Logger.log('ValidationManager', "Email sent")
  end

  def self.validate(user_id, code)
    validation = ValidationRepository.get_validation_by_user_id(user_id)
    if validation.length == 0
      return {error: 'User not found'}
    end
    Logger.log('AuthManager', "Token: #{validation[0]['token']}, Body token: #{code}")
    if validation[0]['token'] != code
      return {error: 'Invalid token'}
    end
    if Time.now > Time.parse(validation[0]['expire_at'])
      return {error: 'Token expired'}
    end
    return {success: 'Token is valid'}
  end
end
