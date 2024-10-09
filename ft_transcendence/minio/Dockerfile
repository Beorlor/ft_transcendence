FROM minio/minio

RUN mkdir -p /scripts

COPY init.sh /scripts/init.sh

COPY default.jpg /default.jpg

RUN chmod +x /scripts/init.sh

ENTRYPOINT ["/bin/sh", "-c", "minio server /data & /scripts/init.sh"]
