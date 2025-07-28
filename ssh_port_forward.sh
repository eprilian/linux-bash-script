#!/bin/bash

# SSH Port Forwarding Manager

SSH_CONFIG="$HOME/.ssh/config"

function show_menu() {
    echo "=============================="
    echo " SSH Port Forwarding Manager"
    echo "=============================="
    echo "1) Create Local Port Forward (Local → Remote)"
    echo "2) Create Remote Port Forward (Remote → Local)"
    echo "3) Create Dynamic Port Forward (SOCKS Proxy)"
    echo "4) List Active SSH Tunnels"
    echo "5) Kill SSH Tunnel by PID"
    echo "0) Exit"
    echo "=============================="
}

function create_local_forward() {
    read -p "SSH user@host: " userhost
    read -p "Local port to forward: " local_port
    read -p "Remote destination (host:port): " remote_dest

    echo "Creating local port forward..."
    ssh -fN -L ${local_port}:${remote_dest} ${userhost}
    echo "Local forward created (localhost:$local_port → $remote_dest via $userhost)"
}

function create_remote_forward() {
    read -p "SSH user@host: " userhost
    read -p "Remote port to open: " remote_port
    read -p "Local destination (host:port): " local_dest

    echo "Creating remote port forward..."
    ssh -fN -R ${remote_port}:${local_dest} ${userhost}
    echo "Remote forward created (remote:$remote_port → $local_dest via $userhost)"
}

function create_dynamic_forward() {
    read -p "SSH user@host: " userhost
    read -p "Local SOCKS proxy port: " socks_port

    echo "Creating SOCKS proxy..."
    ssh -fN -D ${socks_port} ${userhost}
    echo "SOCKS proxy running on localhost:$socks_port"
}

function list_tunnels() {
    echo "Active SSH Tunnels:"
    ps aux | grep "[s]sh -fN" | awk '{print $2, $0}'
}

function kill_tunnel() {
    list_tunnels
    read -p "Enter PID to kill: " pid
    kill "$pid" && echo "Tunnel with PID $pid killed." || echo "Failed to kill process $pid"
}

# Main loop
while true; do
    show_menu
    read -p "Choose an option [0-5]: " choice
    case $choice in
        1) create_local_forward ;;
        2) create_remote_forward ;;
        3) create_dynamic_forward ;;
        4) list_tunnels ;;
        5) kill_tunnel ;;
        0) echo "Exiting..."; break ;;
        *) echo "Invalid option. Try again." ;;
    esac
    echo ""
done
