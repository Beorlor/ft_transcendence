require 'mail'
require 'singleton'

class MailManager
  include Singleton

  def initialize
    Mail.defaults do
      delivery_method :smtp, {
        address: 'smtp4dev',
        port: 25,
        openssl_verify_mode: 'none'
      }
    end
	@logger = Logger.new
  end

  def send_email(from:, to:, subject:, body:)
    mail = Mail.new do
      from    from
      to      to
      subject subject
      body    body
    end

    mail.deliver!
  rescue StandardError => e
    @logger.log('MailManager', "Error sending email: #{e.message}")
  end
end
