require 'json'
require 'net/http'

class UserApi

  def get_user_info(api_url, jwt)
    uri = URI(api_url)
    req = Net::HTTP::Get.new(uri)
    req['Cookie'] = "access_token=#{jwt}"
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.start do |http|
      http.request(req)
    end
    if res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)["user"].first
    else
      nil
    end
  end

end