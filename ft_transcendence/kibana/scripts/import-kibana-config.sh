#!/bin/bash

echo "$(date) Waiting for Kibana to be ready..."

# Wait for Kibana to be available
until curl -s -o /dev/null "http://localhost:5601/api/status"; do
  sleep 5
done

echo "$(date) Kibana is ready. Importing configuration..."

# Import the Kibana configuration
curl -X POST "http://localhost:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  --form file=@/usr/share/kibana/config/nginx_access.ndjson

echo "$(date) Kibana configuration imported successfully!"
