# Base image for Kibana
FROM docker.elastic.co/kibana/kibana:8.12.2

# Switch to root user for file operations
USER root

# Copy the saved objects file and import script
COPY ./config/nginx_access.ndjson /usr/share/kibana/config/kibana-config.ndjson
COPY ./scripts/import-kibana-config.sh /usr/share/kibana/scripts/import-kibana-config.sh

# Make the import script executable
RUN chmod +x /usr/share/kibana/scripts/import-kibana-config.sh

# Switch back to the Kibana user
USER kibana

# Start Kibana and run the import script
CMD ["/bin/bash", "-c", "/usr/share/kibana/bin/kibana & sleep 30 && /usr/share/kibana/scripts/import-kibana-config.sh && tail -f /dev/null"]
