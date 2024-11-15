require_relative '../repository/tournament_repository'

class TournamentManager

  def initialize(logger = Logger.new, tournament_repository = TournamentRepository.new)
    @logger = logger
    @tournament_repository = tournament_repository
  end

  def create_tournament(body, user_id)
    @logger.log('TournamentManager', 'Creating tournament')
    if body['name'].nil? || body['name'].empty? || body['name'].length > 50 || body['name'].length < 3
      return { code: 400, error: 'Invalid tournament name' }
    end
    tournament_info = {
      name: body['name'],
      host_id: user_id,
      start_at: (Time.now + 15 * 60).strftime("%Y-%m-%d %H:%M:%S"),
      updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    tournament = @tournament_repository.create_tournament(tournament_info)
    return { code: 200, success: "Succesfully created", tournament: tournament }
  end

  def get_tournament(tournament_id)
    @logger.log('TournamentManager', "Getting tournament #{tournament_id}")
    tournament = @tournament_repository.get_tournament(tournament_id)
    if tournament.nil?
      return { code: 404, error: 'Tournament not found' }
    end
    { code: 200, tournament: tournament }
  end

  def get_tournaments()
    @logger.log('TournamentManager', 'Getting tournaments')
    tournaments = @tournament_repository.get_tournaments()
    return { code: 200, tournaments: tournaments }
  end

end