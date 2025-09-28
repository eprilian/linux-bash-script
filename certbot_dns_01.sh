#!/bin/bash

# --- Check for root privileges ---
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# --- Check for required arguments ---
if [ -z "$1" ]; then
    echo "Usage: $0 <your-domain>"
    echo "Example: $0 example.com"
    exit 1
fi

domain="$1"
credentials_file=".secrets/cloudflare.ini"

# --- Execute Certbot command ---
echo "Attempting to get a certificate for $domain using DNS-01 challenge..."
echo "Using credentials file: $credentials_file"

certbot certonly \
--dns-cloudflare \
--dns-cloudflare-credentials "$credentials_file" \
-d "$domain" \
--agree-tos \
--register-unsafely-without-email

# --- Check the exit status of Certbot ---
if [ $? -eq 0 ]; then
    echo "Certbot ran successfully. Your certificate has been issued."
else
    echo "Certbot failed. Please check the output for errors."
fi
