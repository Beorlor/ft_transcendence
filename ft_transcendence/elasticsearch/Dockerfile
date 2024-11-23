# elasticsearch/Dockerfile

FROM docker.elastic.co/elasticsearch/elasticsearch:8.12.2

# Install curl
RUN yum update -y && \
    yum install -y curl

COPY elasticsearch.yml /usr/share/elasticsearch/config/
COPY create_users.sh /usr/share/elasticsearch/
RUN chmod +x /usr/share/elasticsearch/create_users.sh

CMD ["/usr/share/elasticsearch/create_users.sh"]
