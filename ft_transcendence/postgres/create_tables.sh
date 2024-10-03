#!/bin/bash

sleep 5

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
CREATE TABLE IF NOT EXISTS _user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(12) NOT NULL,
    email VARCHAR(320) NOT NULL UNIQUE,
    password VARCHAR(255),
    role INTEGER,
    login_type INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _emailActivation (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    token VARCHAR(6) NOT NULL,
    expire_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _ranking (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    points INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _pong (
    id SERIAL PRIMARY KEY,
    player_1_id INTEGER REFERENCES _user(id),
    player_2_id INTEGER REFERENCES _user(id),
    ball_position JSONB,
    position_player_1 JSONB,
    position_player_2 JSONB,
    player_1_score INTEGER,
    player_2_score INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _pongHistory (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    game_id INTEGER REFERENCES _pong(id),
    state INTEGER,
    rank_points INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _zombieHistory (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    game_id INTEGER REFERENCES _zombie(id),
    state INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _zombie (
    id SERIAL PRIMARY KEY,
    stage_number INTEGER NOT NULL,
    player_ids INTEGER[] NOT NULL,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

EOSQL

echo "Tables '_user', '_emailActivation', '_ranking', '_game', et '_gameHistory' vérifiées ou créées avec succès."
