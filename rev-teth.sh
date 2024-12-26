#bash script to easy use gnirehtet
#!/bin/bash

# Log file and PID file for gnirehtet
LOG_FILE="/home/noname/Documents/mainanku/android_script/reverse-tethering/gnirehtet.log"
PID_FILE="/home/noname/Documents/mainanku/android_script/reverse-tethering/gnirehtet.pid"
WINDOW_NAME="ADB REVERSE TETHERING"  # Customizable window name

# Function to check if gnirehtet is running
check_gnirehtet_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            zenity --info --text="Gnirehtet is running (PID: $PID)."
        else
            zenity --info --text="Gnirehtet is not running, but a stale PID file exists."
        fi
    else
        zenity --info --text="Gnirehtet is not running."
    fi
}

# Function to start gnirehtet
start_gnirehtet() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            zenity --info --text="Gnirehtet is already running (PID: $PID)."
            return
        else
            zenity --info --text="Gnirehtet process exists but is not running. Removing stale PID file."
            rm -f "$PID_FILE"
        fi
    fi

    # Run gnirehtet in the background and redirect output to log file
    nohup gnirehtet run >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"
    zenity --info --text="Gnirehtet started (PID: $!)."
}

# Function to stop gnirehtet
stop_gnirehtet() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID" && rm -f "$PID_FILE"
            zenity --info --text="Gnirehtet stopped."
        else
            zenity --info --text="Gnirehtet is not running, removing stale PID file."
            rm -f "$PID_FILE"
        fi
    else
        zenity --info --text="Gnirehtet is not running."
    fi
}

# Function to show logs in real-time
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        tail -f "$LOG_FILE" | zenity --text-info --title="$WINDOW_NAME Logs" --width=800 --height=600
    else
        zenity --error --text="No log file found."
    fi
}

# Main GUI menu with clickable buttons
main_menu() {
    while true; do
        # Show the menu with buttons (in a grid)
        CHOICE=$(zenity --list --title="$WINDOW_NAME" \
            --text="Choose an action:" \
            --column="Action" \
            "Start Service" \
            "Stop Service" \
            "Logs" \
            "Status" \
            "Exit" \
            --height=300 --width=400)

        # If the user clicks "Cancel" (exit status 1), close the app
        if [ $? -eq 1 ]; then
            exit 0
        fi

        case $CHOICE in
            "Start Service") start_gnirehtet ;;
            "Stop Service") stop_gnirehtet ;;
            "Logs") show_logs ;;
            "Status") check_gnirehtet_status ;;
            "Exit") exit 0 ;;
            *) zenity --error --text="Invalid choice. Please try again." ;;
        esac
    done
}

# Detach from terminal and run the menu
main_menu & disown
