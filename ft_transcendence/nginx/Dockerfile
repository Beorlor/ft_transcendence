FROM nginx:alpine

RUN apk add --no-cache openssl

COPY default.conf /etc/nginx/conf.d/default.conf

COPY ssl /etc/nginx/ssl

