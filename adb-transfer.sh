#!/bin/bash

# --- Configuration ---
ADB_PATH="/home/noname/Documents/mainanku/android-adb/adb"	# Adjust if your adb is in a different location
                       					 	# Or leave it as 'adb' if it's in your PATH
                        				 	# You can find it with 'which adb'

# --- Colors for Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Functions ---

check_adb() {
    echo -e "${BLUE}Checking ADB installation...${NC}"
    if command -v "$ADB_PATH" &> /dev/null; then
        echo -e "${GREEN}ADB found: $($ADB_PATH version)${NC}"
        return 0
    else
        echo -e "${RED}Error: ADB not found at '$ADB_PATH'. Please install it or adjust ADB_PATH in the script.${NC}"
        echo -e "${YELLOW}On Debian/Ubuntu: sudo apt install adb${NC}"
        echo -e "${YELLOW}On Fedora/RHEL: sudo dnf install android-tools${NC}"
        exit 1
    fi
}

check_device() {
    echo -e "${BLUE}Checking for connected Android device...${NC}"
    local devices=$("$ADB_PATH" devices | grep -E '\sdevice$|\sunauthorized$')
    
    if [[ -z "$devices" ]]; then
        echo -e "${RED}Error: No Android device found. Please ensure:${NC}"
        echo -e "${YELLOW}- USB debugging is enabled on your phone.${NC}"
        echo -e "${YELLOW}- Your phone is connected via USB.${NC}"
        echo -e "${YELLOW}- You have accepted the 'Allow USB debugging' prompt on your phone.${NC}"
        exit 1
    elif [[ "$devices" == *unauthorized* ]]; then
        echo -e "${RED}Error: Device found but unauthorized. Please check your phone for the 'Allow USB debugging' prompt and accept it.${NC}"
        exit 1
    else
        echo -e "${GREEN}Device connected:${NC}"
        echo -e "${GREEN}$devices${NC}"
        return 0
    fi
}

perform_push() {
    echo -e "${BLUE}--- ADB PUSH (PC to Android) ---${NC}"
    read -rp "Enter local file or folder path (e.g., /home/user/document.pdf or /home/user/my_photos): " local_path

    if [[ ! -e "$local_path" ]]; then
        echo -e "${RED}Error: Local path '$local_path' does not exist.${NC}"
        return 1
    fi

    echo -e "${YELLOW}Common Android paths:${NC}"
    echo -e "${YELLOW}  /sdcard/Download/ (for general downloads)${NC}"
    echo -e "${YELLOW}  /sdcard/DCIM/Camera/ (for photos)${NC}"
    echo -e "${YELLOW}  /sdcard/Music/ (for music)${NC}"
    echo -e "${YELLOW}  /sdcard/Movies/ (for videos)${NC}"
    read -rp "Enter Android destination path (e.g., /sdcard/Download/): " android_dest_path

    # Ensure trailing slash if it's a directory
    if [[ -d "$local_path" ]]; then
        if [[ "${android_dest_path: -1}" != "/" ]]; then
            android_dest_path="${android_dest_path}/"
        fi
    fi

    echo -e "${GREEN}Pushing '$local_path' to '$android_dest_path' on device...${NC}"
    "$ADB_PATH" push "$local_path" "$android_dest_path"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}File/Folder pushed successfully!${NC}"
    else
        echo -e "${RED}Error: Failed to push file/folder.${NC}"
    fi
}

perform_pull() {
    echo -e "${BLUE}--- ADB PULL (Android to PC) ---${NC}"
    echo -e "${YELLOW}Common Android paths:${NC}"
    echo -e "${YELLOW}  /sdcard/Download/ (for general downloads)${NC}"
    echo -e "${YELLOW}  /sdcard/DCIM/Camera/ (for photos)${NC}"
    echo -e "${YELLOW}  /sdcard/WhatsApp/Media/WhatsApp Images/ (for WhatsApp images)${NC}"
    read -rp "Enter Android source file or folder path (e.g., /sdcard/Download/my_doc.pdf or /sdcard/DCIM/Camera/ or /sdcard/Download/*.zip): " android_source_path

    read -rp "Enter local destination folder path (e.g., /home/user/Downloads/ or . for current directory): " local_dest_path

    if [[ ! -d "$local_dest_path" ]]; then
        echo -e "${RED}Error: Local destination path '$local_dest_path' does not exist or is not a directory.${NC}"
        return 1
    fi

    # Handle wildcards: adb pull doesn't support wildcards directly on the device side.
    # For now, we'll assume the user provides a valid path.
    # A more advanced script could use `adb shell find` to list files matching a pattern.

    echo -e "${GREEN}Pulling '$android_source_path' from device to '$local_dest_path'...${NC}"
    "$ADB_PATH" pull "$android_source_path" "$local_dest_path"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}File/Folder pulled successfully!${NC}"
    else
        echo -e "${RED}Error: Failed to pull file/folder.${NC}"
    fi
}

main_menu() {
    while true; do
        echo -e "${BLUE}\n--- ADB File Transfer Script ---${NC}"
        echo -e "${YELLOW}1. Push (PC to Android)${NC}"
        echo -e "${YELLOW}2. Pull (Android to PC)${NC}"
        echo -e "${YELLOW}3. Exit${NC}"
        read -rp "Choose an option: " choice

        case "$choice" in
            1)
                perform_push
                ;;
            2)
                perform_pull
                ;;
            3)
                echo -e "${GREEN}Exiting script. Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please choose 1, 2, or 3.${NC}"
                ;;
        esac
        echo "" # Add a blank line for readability
    done
}

# --- Main Execution ---
check_adb
check_device
main_menu
