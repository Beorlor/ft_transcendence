#!/bin/bash

sleep 5

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
CREATE TABLE IF NOT EXISTS _user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(12) NOT NULL,
    img_url VARCHAR(255) NOT NULL DEFAULT 'http://localhost:9000/profiles/default.jpg',
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

CREATE TABLE IF NOT EXISTS _pong (
    id SERIAL PRIMARY KEY,
    player_1_id INTEGER REFERENCES _user(id),
    player_2_id INTEGER REFERENCES _user(id),
    state INTEGER,
    rank_points INTEGER,
    player_1_score INTEGER,
    player_2_score INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _pongHistory (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES _user(id),
    nb_win INTEGER,
    nb_lose INTEGER,
    nb_game INTEGER,
    rank_points INTEGER,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS _friendship (
    id SERIAL PRIMARY KEY,
    requester_id INTEGER REFERENCES _user(id) ON DELETE CASCADE,
    receiver_id INTEGER REFERENCES _user(id) ON DELETE CASCADE,
    status VARCHAR(10) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

EOSQL

echo "Tables '_user', '_emailActivation', '_ranking', '_game', et '_gameHistory' vérifiées ou créées avec succès."
