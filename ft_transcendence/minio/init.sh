#!/bin/sh

BUCKET_NAME=profiles
DEFAULT_IMAGE_KEY=default.jpg

minio server /data &

until curl -s http://localhost:9000/minio/health/live; do
  sleep 1
done

mc alias set local http://localhost:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD

mc mb local/$BUCKET_NAME || true

if ! mc stat local/$BUCKET_NAME/$DEFAULT_IMAGE_KEY; then
  echo "Uploading default image..."
  mc cp /default.jpg local/$BUCKET_NAME/$DEFAULT_IMAGE_KEY
else
  echo "Default image already exists."
fi

wait
