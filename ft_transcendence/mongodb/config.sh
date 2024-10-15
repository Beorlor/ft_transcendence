#!/bin/bash

# Attendre que MongoDB soit prêt
until mongosh --host localhost --port 27017 -u user -p password --authenticationDatabase admin --eval "print(\"waiting for connection\")"; do
    echo "Waiting for MongoDB to start..."
    sleep 5
done

# Créer la base de données et la collection
mongosh --host localhost --port 27017 -u user -p password --authenticationDatabase admin <<EOF
use ft_transcendence_db
db.createCollection('images')
EOF
