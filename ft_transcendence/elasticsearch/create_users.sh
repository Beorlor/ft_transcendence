#!/bin/bash

# Wait for Elasticsearch to start
echo "Waiting for Elasticsearch to start..."
until curl -s -k http://localhost:9200 >/dev/null; do
  sleep 5
done

# Set password for 'elastic' user
echo "Setting password for 'elastic' user..."
/usr/share/elasticsearch/bin/elasticsearch-users passwd elastic -p "$ELASTIC_PASSWORD"

# Set password for 'kibana_system' user
echo "Setting password for 'kibana_system' user..."
/usr/share/elasticsearch/bin/elasticsearch-users passwd kibana_system -p "$KIBANA_PASSWORD"

# Keep the container running
tail -f /dev/null
