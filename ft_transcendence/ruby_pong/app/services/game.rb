

class Game
  attr_accessor :client1, :client2, :score, :status

  def initialize(client1, client2)
    @client1 = client1
    @client2 = client2
    @client1[:ws].send('game created you are client 1')
    @client2[:ws].send('game created you are client 2')
    @score = { client1: 0, client2: 0 }
    @status = 'active'
  end

  def update_score(client, points)
    @score[client] += points
  end
end
