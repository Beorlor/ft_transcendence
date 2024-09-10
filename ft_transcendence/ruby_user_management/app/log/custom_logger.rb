require 'tzinfo'

class Logger
  @log_file = "app.log"
  @timezone = TZInfo::Timezone.get('Europe/Paris')

  class << self
    def log_file=(file)
      @log_file = file
    end

    def log_file
      @log_file
    end

    def log(where, message)
      File.open(@log_file, "a") do |file|
        file.puts("[#{current_time}] - #{where} => #{message}")
      end
    end
    
    def current_time
      @timezone.now.strftime("%Y-%m-%d %H:%M:%S")
    end

  end
end