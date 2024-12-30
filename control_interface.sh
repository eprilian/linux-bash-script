#!/bin/bash

# Log file to track actions
LOG_FILE="/var/log/network_control.log"

# Function to bring the interface up
bring_up() {
    echo "$(date) - Bringing interface $1 UP" >> $LOG_FILE
    sudo ifconfig $1 up
    echo "Interface $1 is now UP."
}

# Function to bring the interface down
bring_down() {
    echo "$(date) - Bringing interface $1 DOWN" >> $LOG_FILE
    sudo ifconfig $1 down
    echo "Interface $1 is now DOWN."
}

# Function to get interface status (Up or Down)
get_status() {
    status=$(ip link show $1 | grep -oP '(?<=state )\w+')
    echo "$status"
}

# Function to get IP address of the interface
get_ip() {
    ip_addr=$(ip addr show $1 | grep -oP '(?<=inet )[\d.]+')
    echo "$ip_addr"
}

# Function to get detailed information about the interface
get_details() {
    echo "Interface Details:"
    ip addr show $1
}

# Show network interfaces
interfaces=$(ip -o link show | awk -F': ' '{print $2}')

# Check if Zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Please install Zenity to use the GUI."
    exit 1
fi

# Main loop
while true; do
    # Create a GUI dialog to choose action
    ACTION=$(zenity --list --title="Network Interface Control" --column="Action" \
                    "Bring Up" "Bring Down" "Interface Status" "Show IP Address" "Interface Details" "Exit")

    if [ $? -ne 0 ]; then
        echo "Stopped!"
        exit 1
    fi

    # Create a GUI dialog to choose network interface
    INTERFACE=$(zenity --list --title="Select Network Interface" --column="Interface" $interfaces)

    if [ $? -ne 0 ]; then
        echo "Stopped!"
        exit 1
    fi

    # Handle different actions based on user choice
    case $ACTION in
        "Bring Up")
            STATUS=$(get_status $INTERFACE)
            if [ "$STATUS" == "UP" ]; then
                zenity --info --text="Interface $INTERFACE is already UP."
            else
                bring_up $INTERFACE
            fi
            ;;
        "Bring Down")
            STATUS=$(get_status $INTERFACE)
            if [ "$STATUS" == "DOWN" ]; then
                zenity --info --text="Interface $INTERFACE is already DOWN."
            else
                bring_down $INTERFACE
            fi
            ;;
        "Interface Status")
            STATUS=$(get_status $INTERFACE)
            zenity --info --text="The status of $INTERFACE is: $STATUS"
            ;;
        "Show IP Address")
            IP_ADDR=$(get_ip $INTERFACE)
            if [ -z "$IP_ADDR" ]; then
                zenity --info --text="No IP address found for $INTERFACE."
            else
                zenity --info --text="The IP address of $INTERFACE is: $IP_ADDR"
            fi
            ;;
        "Interface Details")
            get_details $INTERFACE | zenity --text-info --title="Interface Details" --width=600 --height=400
            ;;
        "Exit")
            echo "Exiting the application."
            exit 0
            ;;
        *)
            echo "Invalid action selected."
            exit 1
            ;;
    esac
done
