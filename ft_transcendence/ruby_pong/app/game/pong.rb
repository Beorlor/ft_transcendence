class Pong

  def initialize(logger = Logger.new)
    @logger = logger
    @users = []
  end

  def create_game(client1, client2)
    client1.send('game created you are player 1')
    client2.send('game created you are player 2')
  end

  def matchmaking_normal(client, event)
    @users.push(client)
    if @users.size == 2
      create_game(@users.shift, @users.shift)
    end
  end
end