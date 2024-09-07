module CustomLogger
	LOG_FILE = 'logs/app.log'

	def self.log(message)
	  File.open(LOG_FILE, 'a') do |f|
		f.puts("#{Time.now}: #{message}")
	  end
	  puts message
	end
  end
