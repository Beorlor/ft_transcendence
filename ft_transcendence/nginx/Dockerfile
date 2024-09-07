FROM nginx:alpine

COPY default.conf /etc/nginx/conf.d/default.conf
COPY generate_cert.sh /etc/nginx/generate_cert.sh

RUN chmod +x /etc/nginx/generate_cert.sh && /etc/nginx/generate_cert.sh
