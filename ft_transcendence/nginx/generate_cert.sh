#!/bin/bash

# Ensure the certs directory exists
mkdir -p ./nginx/certs

# Check if mkcert is installed, if not install it
if ! command -v mkcert &> /dev/null; then
    echo "mkcert is not installed. Installing mkcert..."
    sudo apt update
    sudo apt install libnss3-tools -y  # Required for mkcert on Linux
    wget https://dl.filippo.io/mkcert/latest?for=linux/amd64 -O mkcert
    chmod +x mkcert
    sudo mv mkcert /usr/local/bin/
fi

# Install the local CA and trust it
mkcert -install

# Ensure permissions to write certs in ./nginx/certs
sudo chmod -R 755 ./nginx/certs

# Generate certificates for localhost
echo "Generating certificates for localhost..."
mkcert -cert-file ./nginx/certs/localhost.pem -key-file ./nginx/certs/localhost-key.pem localhost 127.0.0.1 ::1

# Generate DHParam for stronger security
openssl dhparam -out ./nginx/certs/dhparam.pem 2048

# Ensure proper ownership of the generated certificates
sudo chown -R $USER:$USER ./nginx/certs
sudo chmod -R 755 ./nginx/certs

echo "Certificates generated and stored in ./nginx/certs."
