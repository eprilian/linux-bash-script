#!/bin/bash

# Check if warp-cli is installed
if ! command -v warp-cli &>/dev/null; then
    echo "Error: warp-cli is not installed. Please install Cloudflare Warp CLI first."
    exit 1
fi

# Function to display a menu and get the user's choice
show_menu() {
    echo "================== Warp CLI Manager =================="
    echo "1. Connect"
    echo "2. Disconnect"
    echo "3. Check Status"
#    echo "4. Set DNS Settings"
#    echo "5. Set Mode"
#    echo "6. Configure Proxy Mode"
#    echo "7. Show Debug Info"
#    echo "8. Configure Tunnel"
#    echo "9. Show Settings"
#    echo "10. Manage Trusted Networks"
#    echo "11. Exit"
    echo "0. Exit"
    echo "======================================================="
    read -p "Select an option [0-3]!: " choice
}

# Function to connect to Warp
connect_warp() {
    echo "Connecting to Warp..."
    warp-cli connect
    if [ $? -eq 0 ]; then
        echo "Warp connected successfully!"
    else
        echo "Failed to connect to Warp."
    fi
}

# Function to disconnect from Warp
disconnect_warp() {
    echo "Disconnecting from Warp..."
    warp-cli disconnect
    if [ $? -eq 0 ]; then
        echo "Warp disconnected successfully!"
    else
        echo "Failed to disconnect from Warp."
    fi
}

# Function to check the status of Warp
check_status() {
    echo "Checking Warp status..."
    warp-cli status
}

# Function to configure DNS settings
configure_dns() {
    echo "Configuring DNS settings..."
    warp-cli dns
}

# Function to set the operating mode (Warp / Warp+)
set_mode() {
    echo "Setting operating mode..."
    warp-cli mode
}

# Function to configure proxy mode settings
configure_proxy() {
    echo "Configuring Proxy Mode settings..."
    warp-cli proxy
}

# Function to show debug info
show_debug_info() {
    echo "Displaying debug information..."
    warp-cli debug
}

# Function to configure tunnel settings
configure_tunnel() {
    echo "Configuring tunnel settings..."
    warp-cli tunnel
}

# Function to show general settings
show_settings() {
    echo "Showing application settings..."
    warp-cli settings
}

# Function to manage trusted networks
manage_trusted_networks() {
    echo "Managing trusted networks..."
    warp-cli trusted
}

# Main menu loop
while true; do
    show_menu
    case $choice in
        1) connect_warp ;;
        2) disconnect_warp ;;
        3) check_status ;;
#        4) configure_dns ;;
#        5) set_mode ;;
#        6) configure_proxy ;;
#        7) show_debug_info ;;
#        8) configure_tunnel ;;
#        9) show_settings ;;
#        10) manage_trusted_networks ;;
        0) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option, please select a number between 1 and 4!" ;;
    esac
done
