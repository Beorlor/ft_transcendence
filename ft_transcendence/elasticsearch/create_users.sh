#!/bin/bash

# Wait for Elasticsearch to start
echo "Waiting for Elasticsearch to start..."
until curl -s -k http://localhost:9200 >/dev/null; do
  sleep 5
done

# Set password for 'elastic' user
echo "Setting password for 'elastic' user..."
echo "$ELASTIC_PASSWORD" | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic --auto -b

# Set password for 'kibana_system' user
echo "Setting password for 'kibana_system' user..."
echo "$KIBANA_PASSWORD" | /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system --auto -b
