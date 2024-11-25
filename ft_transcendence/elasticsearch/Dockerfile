FROM docker.elastic.co/elasticsearch/elasticsearch:8.12.2

# Switch to root user to install additional packages
USER root

# Install curl (if needed)
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

# Copy your custom script
COPY create_users.sh /usr/local/bin/create_users.sh
RUN chmod +x /usr/local/bin/create_users.sh

# Switch back to the elasticsearch user
USER elasticsearch

# Copy your elasticsearch.yml configuration
COPY elasticsearch.yml /usr/share/elasticsearch/config/

# Use the default ENTRYPOINT and CMD
