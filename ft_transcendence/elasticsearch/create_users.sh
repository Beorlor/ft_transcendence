# elasticsearch/create_users.sh

#!/bin/bash

# Start Elasticsearch in the background
/usr/local/bin/docker-entrypoint.sh &

# Wait for Elasticsearch to start
until curl -s -k http://localhost:9200 >/dev/null; do
  echo "Waiting for Elasticsearch to start..."
  sleep 5
done

# Set password for elastic user
echo "Setting password for elastic user..."
curl -s -k -X POST "http://localhost:9200/_security/user/elastic/_password" \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"$ELASTIC_PASSWORD\"}"

# Authenticate as elastic user from now on
AUTH="-u elastic:$ELASTIC_PASSWORD"

# Set password for kibana_system user
echo "Setting password for kibana_system user..."
curl -s -k -X POST "http://localhost:9200/_security/user/kibana_system/_password" \
  $AUTH \
  -H "Content-Type: application/json" \
  -d "{\"password\":\"$KIBANA_PASSWORD\"}"

# Bring Elasticsearch to the foreground
wait -n
