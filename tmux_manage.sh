#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function list_sessions() {
    echo -e "${GREEN}Active tmux sessions:${NC}"
    tmux ls 2>/dev/null || echo "No tmux sessions found."
}

function create_session() {
    read -p "Enter a name for the new session: " session_name
    tmux new-session -s "$session_name"
}

function attach_session() {
    list_sessions
    read -p "Enter the name of the session to attach to: " session_name
    tmux attach-session -t "$session_name"
}

function kill_session() {
    list_sessions
    read -p "Enter the name of the session to kill: " session_name
    tmux kill-session -t "$session_name"
    echo "Session '$session_name' has been terminated."
}

function kill_all_sessions() {
    read -p "Are you sure you want to kill ALL sessions? (y/n): " confirm
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        tmux kill-server
        echo "All tmux sessions have been terminated."
    else
        echo "Operation cancelled."
    fi
}

function menu() {
    echo -e "${GREEN}== TMUX MANAGER ==${NC}"
    echo "1. List active sessions"
    echo "2. Create a new session"
    echo "3. Attach to a session"
    echo "4. Kill a session"
    echo "5. Kill all sessions"
    echo "0. Exit"
    echo
    read -p "Choose an option [0-5]: " choice

    case $choice in
        1) list_sessions ;;
        2) create_session ;;
        3) attach_session ;;
        4) kill_session ;;
        5) kill_all_sessions ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option!" ;;
    esac
}

while true; do
    menu
    echo
done
