#!/bin/bash

echo "Detecting connected Android devices..."

# Get the list of devices, filter out "List of devices attached", and extract serials
# We use `awk` to get the first column (serial) and `sed` to remove empty lines
devices=$(adb devices -l | grep " device " | awk '{print $1}' | sed '/^$/d')

# Convert the string of devices into a bash array
IFS=$'\n' read -r -d '' -a device_array <<< "$devices"

num_devices=${#device_array[@]}

if [ "$num_devices" -eq 0 ]; then
    echo "No Android devices found."
    echo "Please ensure:"
    echo "  1. ADB debugging is enabled on your device."
    echo "  2. Devices are properly connected (USB or wirelessly via 'adb connect IP:PORT')."
    exit 1
fi

# ---

while true; do
    echo ""
    echo "---"
    echo "Found $num_devices device(s):"
    for i in "${!device_array[@]}"; do
        echo "$((i+1)). ${device_array[i]}"
    done
    echo "---"
    echo ""

    echo "Choose an option:"
    echo "  1. Connect to a specific device "
    echo "  2. Connect to all detected device "
    echo "  3. Exit"
    read -p "Enter your choice (1, 2, or 3): " main_choice

     case "$main_choice" in
        1)
            # Option 1: Connect to a specific device
            if [ "$num_devices" -eq 1 ]; then
                echo "Only one device found: ${device_array[0]}"
                echo "Starting scrcpy for ${device_array[0]} (no console, no log output)..."
                # Redirect stdout (1) and stderr (2) to /dev/null
                scrcpy --serial "${device_array[0]}" > /dev/null 2>&1 &
            else
                while true; do
                    read -p "Enter the number of the device you want to connect to (1-$num_devices): " specific_choice
                    if [[ "$specific_choice" =~ ^[0-9]+$ ]] && [ "$specific_choice" -ge 1 ] && [ "$specific_choice" -le "$num_devices" ]; then
                        selected_serial="${device_array[$((specific_choice-1))]}"
                        echo "Starting scrcpy for $selected_serial (no console, no log output)..."
                        # Redirect stdout (1) and stderr (2) to /dev/null
                        scrcpy --serial "$selected_serial" > /dev/null 2>&1 &
                        break # Break out of inner loop, main loop will re-prompt
                    else
                        echo "Invalid choice. Please enter a number between 1 and $num_devices."
                    fi
                done
            fi
            ;;
        2)
            # Option 2: Connect to all device
            echo "Starting scrcpy for all $num_devices connected devices (no console, no log output)..."
            for serial in "${device_array[@]}"; do
                echo "Launching scrcpy for $serial..."
                # Redirect stdout (1) and stderr (2) to /dev/null
                scrcpy --serial "$serial" > /dev/null 2>&1 &
            done
            echo "All scrcpy instances launched. Close their windows to disconnect."
            ;;
        3)
            # Option 3: Exit
            echo "Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option, please enter valid option!"
            ;;
    esac
    # Short pause to ensure scrcpy has time to launch before re-prompting
    sleep 1
done