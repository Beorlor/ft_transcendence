require 'pg'

sleep(5)

conn = PG.connect(
  dbname: ENV['POSTGRES_DB'],
  user: ENV['POSTGRES_USER'],
  password: ENV['POSTGRES_PASSWORD'],
  host: 'postgres',
  port: 5432
)

create_user_table_query = <<-SQL
  CREATE TABLE IF NOT EXISTS _user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(12) NOT NULL,
    email VARCHAR(320) NOT NULL UNIQUE,
    password VARCHAR(255),
    role INTEGER,
    login_type INTEGER,
    actived_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
SQL

create_email_activation_table_query = <<-SQL
  CREATE TABLE IF NOT EXISTS _emailActivation (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    token VARCHAR(6) NOT NULL,
    expire_at TIMESTAMP,
    updated_at TIMESTAMP
  );
SQL

create_ranking_table_query = <<-SQL
  CREATE TABLE IF NOT EXISTS _ranking (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    points INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
SQL

create_game_table_query = <<-SQL
  CREATE TABLE IF NOT EXISTS _game (
    id SERIAL PRIMARY KEY,
    player_1_id INTEGER REFERENCES _user(id),
    player_2_id INTEGER REFERENCES _user(id),
    player_1_score INTEGER,
    player_2_score INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
SQL

create_game_history_table_query = <<-SQL
  CREATE TABLE IF NOT EXISTS _gameHistory (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    game_id INTEGER REFERENCES _game(id),
    state INTEGER,
    rank_points INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  );
SQL

conn.exec(create_user_table_query)
conn.exec(create_email_activation_table_query)
conn.exec(create_ranking_table_query)
conn.exec(create_game_table_query)
conn.exec(create_game_history_table_query)

puts "Tables '_user', '_emailActivation', '_ranking', '_game', et '_gameHistory' vérifiées ou créées avec succès."

conn.close