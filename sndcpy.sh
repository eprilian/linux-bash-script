#bash script to run sndcpy on linux
#!/bin/bash

# Paths
SNDCPY_DIR="/home/noname/Documents/mainanku/android_script/soundcpy"
LOG_FILE="/home/noname/Documents/mainanku/android_script/log/sndcpy.log"
PID_FILE="/home/noname/Documents/mainanku/android_script/log/sndcpy.pid"

# Ensure the log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Start function
start_sndcpy() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "sndcpy is already running with PID $(cat "$PID_FILE")."
        return
    fi

    if [ -d "$SNDCPY_DIR" ]; then
        cd "$SNDCPY_DIR" || {
            echo "Error: Failed to change directory to $SNDCPY_DIR" >> "$LOG_FILE"
            exit 1
        }
        echo "Starting sndcpy from $SNDCPY_DIR..." >> "$LOG_FILE"

        nohup ./sndcpy >> "$LOG_FILE" 2>&1 &
        echo $! > "$PID_FILE"

        echo "sndcpy started with PID $(cat "$PID_FILE"). Logs are being written to $LOG_FILE."
    else
        echo "Error: Directory $SNDCPY_DIR does not exist."
        exit 1
    fi
}

# Stop function
stop_sndcpy() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        kill $(cat "$PID_FILE") && rm -f "$PID_FILE"
        echo "sndcpy stopped."
    else
        echo "sndcpy is not running."
    fi
}

# Status function
status_sndcpy() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "sndcpy is running with PID $(cat "$PID_FILE")."
    else
        echo "sndcpy is not running."
    fi
}

# Display menu
while true; do
    clear
    echo "========================="
    echo " SNDCPY Management Menu "
    echo "========================="
    echo "1. Start sndcpy"
    echo "2. Stop sndcpy"
    echo "3. Check sndcpy Status"
    echo "4. Exit"
    echo "========================="
    read -rp "Enter command: " choice

    case "$choice" in
        1)
            start_sndcpy
            read -rp "Press Enter to continue..." ;;
        2)
            stop_sndcpy
            read -rp "Press Enter to continue..." ;;
        3)
            status_sndcpy
            read -rp "Press Enter to continue..." ;;
        4)
            echo "Close the program!"
            exit 0 ;;
        *)
            echo "Invalid, Please try again."
            read -rp "Press Enter to continue..." ;;
    esac
done
