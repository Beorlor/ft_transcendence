require 'json'
require 'em-http-request'

class UserApi

  def get_user_info(api_url, jwt, &callback)
    http = EM::HttpRequest.new(api_url).get(
      head: { 'Cookie' => "access_token=#{jwt}" })
    http.callback do
      if http.response_header.status == 200
        callback.call(JSON.parse(http.response)["user"][0]) if callback
      else
        callback.call(nil) if callback
      end
    end
    
    http.errback do
      callback.call(nil) if callback
    end
  end

end