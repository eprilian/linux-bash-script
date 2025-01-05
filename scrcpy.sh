#bash script to run scrcpy on linux
#!/bin/bash

# Paths
LOG_FILE="/home/noname/Documents/mainanku/android_script/log/scrcpy.log"
PID_FILE="/home/noname/Documents/mainanku/android_script/log/scrcpy.pid"

# Ensure the log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Start function
start_scrcpy() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "scrcpy is already running with PID $(cat "$PID_FILE")."
        return
    fi

    echo "Starting scrcpy..." >> "$LOG_FILE"

    nohup scrcpy >> "$LOG_FILE" 2>&1 &
    echo $! > "$PID_FILE"

    echo "scrcpy started with PID $(cat "$PID_FILE"). Logs are being written to $LOG_FILE."
}

# Stop function
stop_scrcpy() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        kill $(cat "$PID_FILE") && rm -f "$PID_FILE"
        echo "scrcpy stopped."
    else
        echo "scrcpy is not running."
    fi
}

# Status function
status_scrcpy() {
    if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
        echo "scrcpy is running with PID $(cat "$PID_FILE")."
    else
        echo "scrcpy is not running."
    fi
}

# Display menu
while true; do
    clear
    echo "========================="
    echo " SCRCPY Management Menu "
    echo "========================="
    echo "1. Start scrcpy"
    echo "2. Stop scrcpy"
    echo "3. Check scrcpy Status"
    echo "4. Exit"
    echo "========================="
    read -rp "Enter command: " choice

    case "$choice" in
        1)
            start_scrcpy
            read -rp "Press Enter to continue..." ;;
        2)
            stop_scrcpy
            read -rp "Press Enter to continue..." ;;
        3)
            status_scrcpy
            read -rp "Press Enter to continue..." ;;
        4)
            echo "Close the program!"
            exit 0 ;;
        *)
            echo "Invalid, Please try again."
            read -rp "Press Enter to continue..." ;;
    esac
done
