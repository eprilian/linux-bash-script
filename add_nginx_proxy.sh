#!/bin/bash

# A simple Bash script to add an Nginx reverse proxy configuration.

# --- User Input ---
# Prompt the user to enter the domain name
read -p "Enter the domain name (e.g., example.com): " domain
if [ -z "$domain" ]; then
    echo "Error: Domain name cannot be empty."
    exit 1
fi

# Prompt the user for the backend server address (IP or hostname) and port
read -p "Enter the backend address and port (e.g., http://localhost:3000): " backend_url
if [ -z "$backend_url" ]; then
    echo "Error: Backend URL cannot be empty."
    exit 1
fi

# --- File Paths ---
sites_available_dir="/etc/nginx/sites-available"
sites_enabled_dir="/etc/nginx/sites-enabled"
config_file="$sites_available_dir/$domain"

# --- Create Nginx Config ---
echo "Creating Nginx configuration file at $config_file"
sudo bash -c "cat > $config_file <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $domain;

    location / {
        proxy_pass $backend_url;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF"

# --- Enable the Config ---
echo "Enabling the new configuration..."
sudo ln -s "$config_file" "$sites_enabled_dir/"

# --- Test and Reload Nginx ---
echo "Testing Nginx configuration for syntax errors..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "Configuration test successful. Reloading Nginx..."
    sudo systemctl reload nginx
    echo "Nginx successfully reloaded. Your reverse proxy is now active."
    echo "You should now be able to access your application at http://$domain"
else
    echo "Nginx configuration test failed. Please check the file for errors."
    echo "The symlink has been created but Nginx has NOT been reloaded."
fi
