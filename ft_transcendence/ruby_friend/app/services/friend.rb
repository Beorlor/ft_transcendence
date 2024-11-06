require_relative '../log/custom_logger'
require_relative 'external/user_api'

class Friend

  def initialize(logger = Logger.new, user_api = UserApi.new)
    @logger = logger
    @user_api = user_api
    @user_connections = {}
  end

  def add_friend(user_id)
    if @user_connections[user_id]
      @user_connections[user_id].send({type: 'friend_request'}.to_json)
    end
  end

  def friend(client, cookie)
    jwt = cookie['access_token']
    @user_api.user_logged(jwt) do |user|
      if user
        @user_connections[user["user_id"]] = client
        @logger.log('Friend', "User connected: #{user}")
        @user_api.get_user_friends(user["user_id"]) do |friends|
          if friends
            friends.each do |friend|
              @logger.log('Friend', "Friend: #{friend}")
              if @user_connections[friend["requester_id"]] && friend["requester_id"].to_i != user["user_id"].to_i && friend["status"] == "accepted"
                @user_connections[friend["requester_id"]].send({type: 'friend_connected', friend: user["user_id"]}.to_json)
                client.send({type: 'friend_connected', friend: friend["requester_id"]}.to_json)
              elsif @user_connections[friend["receiver_id"]] && friend["receiver_id"].to_i != user["user_id"].to_i && friend["status"] == "accepted"
                @user_connections[friend["receiver_id"]].send({type: 'friend_connected', friend: user["user_id"]}.to_json)
                client.send({type: 'friend_connected', friend: friend["receiver_id"]}.to_json)
              end
            end
          end
        end
        client.onclose do
          @logger.log('Friend', "User disconnected: #{user}")
          @user_connections.delete(user["user_id"])
          @user_api.get_user_friends(user["user_id"]) do |friends|
            if friends
              friends.each do |friend|
                if @user_connections[friend["requester_id"]] && friend["requester_id"].to_i != user["user_id"].to_i
                  @user_connections[friend["requester_id"]].send({type: 'friend_disconnected', friend: user["user_id"]}.to_json)
                elsif @user_connections[friend["receiver_id"]] && friend["receiver_id"].to_i != user["user_id"].to_i
                  @user_connections[friend["receiver_id"]].send({type: 'friend_disconnected', friend: user["user_id"]}.to_json)
                end
              end
            end
          end
        end
        client.onmessage do |message|
          begin
            data = JSON.parse(message)
            case data["type"]
            when 'add_friend'
              add_friend(data["user_id"])
            end
          rescue JSON::ParserError => e
            @logger.log('Friend', "Invalid JSON: #{message}")
          end
        end

      else
        @logger.log('Friend', "Unauthorized user")
        client.send({error: 'Unauthorized'}.to_json)
        client.close
      end
    end
  end
end