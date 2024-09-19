# In Dockerfile for nginx
FROM nginx:alpine

RUN apk add --no-cache openssl

# Ensure that the certs directory exists and has the correct permissions
RUN mkdir -p /etc/nginx/certs && chmod -R 755 /etc/nginx/certs

# Copy the default configuration
COPY default.conf /etc/nginx/conf.d/default.conf
