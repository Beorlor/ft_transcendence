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
    puts "Erreur lors de l'envoi de l'email: #{e.message}"
  end
end
