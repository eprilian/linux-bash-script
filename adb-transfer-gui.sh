#!/bin/bash

# --- Configuration ---
ADB_PATH="/home/noname/Documents/mainanku/android-adb/adb" # Adjust if your adb is in a different location

# --- Global Variables ---
SELECTED_DEVICE="" # To store the serial number of the selected device

# --- Check for GUI Tool ---
GUI_TOOL=""
if command -v zenity &> /dev/null; then
    GUI_TOOL="zenity"
elif command -v yad &> /dev/null; then
    GUI_TOOL="yad"
elif command -v kdialog &> /dev/null; then
    GUI_TOOL="kdialog"
else
    echo "Error: No GUI dialog tool (Zenity, Yad, or Kdialog) found."
    echo "Please install one (e.g., sudo apt install zenity) to run this script with a GUI."
    exit 1
fi

# --- Helper Functions for GUI ---

show_info() {
    "$GUI_TOOL" --info --text="$1" --title="Info"
}

show_error() {
    "$GUI_TOOL" --error --text="$1" --title="Error"
}

show_question() {
    "$GUI_TOOL" --question --text="$1" --title="Confirm"
    return $? # Returns 0 for Yes, 1 for No
}

get_text_input() {
    "$GUI_TOOL" --entry --text="$1" --title="Input Required" --entry-text="$2"
    echo $? > /dev/null # Discard zenity exit code as we use the output
}

select_file() {
    "$GUI_TOOL" --file-selection --title="$1" --filename="$HOME/"
}

select_directory() {
    "$GUI_TOOL" --file-selection --directory --title="$1" --filename="$HOME/"
}

select_from_list() {
    local title="$1"
    shift
    local columns=("$@")
    local cmd=("$GUI_TOOL" --list --title="$title" --hide-column=1 --column="Serial" --column="Status")
    
    # Add items to the command
    for item in "${columns[@]}"; do
        cmd+=("$item")
    done
    
    "${cmd[@]}"
}


# --- Core Functions (modified to use GUI) ---

check_adb() {
    if ! command -v "$ADB_PATH" &> /dev/null; then
        show_error "ADB not found. Please install it or adjust ADB_PATH in the script."
        exit 1
    fi
}

select_device() {
    local devices_output=$("$ADB_PATH" devices)
    local devices_raw=$(echo "$devices_output" | grep -E '\sdevice$|\sunauthorized$')
    
    if [[ -z "$devices_raw" ]]; then
        show_error "No Android device found. Ensure USB debugging is enabled and the device is connected."
        exit 1
    fi

    local device_list=()
    while IFS= read -r line; do
        local serial=$(echo "$line" | awk '{print $1}')
        local status=$(echo "$line" | awk '{print $2}')
        device_list+=("$serial" "$status")
    done <<< "$devices_raw"

    if [[ ${#device_list[@]} -eq 2 ]]; then # Only one device (serial + status)
        SELECTED_DEVICE="${device_list[0]}"
        if [[ "${device_list[1]}" == "unauthorized" ]]; then
             show_error "Device '$SELECTED_DEVICE' is unauthorized. Accept the 'Allow USB debugging' prompt on your phone."
             exit 1
        fi
    else # Multiple devices, or initial setup (will be handled by main menu selection)
        local chosen_device=$(select_from_list "Select Android Device" "${device_list[@]}")
        if [[ -z "$chosen_device" ]]; then
            show_error "No device selected. Exiting."
            exit 1
        fi
        
        local status=$(echo "$devices_raw" | grep "$chosen_device" | awk '{print $2}')
        if [[ "$status" == "unauthorized" ]]; then
            show_error "Device '$chosen_device' is unauthorized. Accept the 'Allow USB debugging' prompt on your phone."
            exit 1
        fi
        SELECTED_DEVICE="$chosen_device"
    fi
}

perform_push() {
    local local_path=$(select_file "Select file or folder to PUSH to Android")
    if [[ -z "$local_path" ]]; then
        show_info "No local file/folder selected. Operation cancelled."
        return 1
    fi

    if [[ ! -e "$local_path" ]]; then
        show_error "Local path '$local_path' does not exist."
        return 1
    fi

    local android_dest_path=$(get_text_input "Enter Android destination path (e.g., /sdcard/Download/):\n\nCommon paths:\n  /sdcard/Download/\n  /sdcard/DCIM/Camera/\n  /sdcard/Music/" "/sdcard/Download/")
    if [[ -z "$android_dest_path" ]]; then
        show_info "Android destination path cannot be empty. Operation cancelled."
        return 1
    fi

    if [[ -d "$local_path" ]]; then
        if [[ "${android_dest_path: -1}" != "/" ]]; then
            android_dest_path="${android_dest_path}/"
        fi
    fi

    show_info "Pushing '$local_path' to '$android_dest_path' on device '$SELECTED_DEVICE'..."
    local output=$("$ADB_PATH" -s "$SELECTED_DEVICE" push "$local_path" "$android_dest_path" 2>&1)
    if [[ $? -eq 0 ]]; then
        show_info "File/Folder pushed successfully!\n\n$output"
    else
        show_error "Error: Failed to push file/folder.\n\n$output"
    fi
}

perform_pull() {
    local android_source_path=$(get_text_input "Enter Android source file or folder path (e.g., /sdcard/Download/my_doc.pdf or /sdcard/DCIM/Camera/):\n\nCommon paths:\n  /sdcard/Download/\n  /sdcard/DCIM/Camera/\n  /sdcard/WhatsApp/Media/WhatsApp Images/" "/sdcard/Download/")
    if [[ -z "$android_source_path" ]]; then
        show_info "Android source path cannot be empty. Operation cancelled."
        return 1
    fi

    local local_dest_path=$(select_directory "Select local destination folder (on your PC)")
    if [[ -z "$local_dest_path" ]]; then
        show_info "No local destination folder selected. Operation cancelled."
        return 1
    fi

    show_info "Pulling '$android_source_path' from device '$SELECTED_DEVICE' to '$local_dest_path'..."
    local output=$("$ADB_PATH" -s "$SELECTED_DEVICE" pull "$android_source_path" "$local_dest_path" 2>&1)
    if [[ $? -eq 0 ]]; then
        show_info "File/Folder pulled successfully!\n\n$output"
    else
        show_error "Error: Failed to pull file/folder.\n\n$output"
    fi
}

install_apk() {
    local apk_path=$(select_file "Select the APK file to install")
    if [[ -z "$apk_path" ]]; then
        show_info "No APK file selected. Operation cancelled."
        return 1
    fi

    if [[ ! -f "$apk_path" || "${apk_path##*.}" != "apk" ]]; then
        show_error "Invalid APK path. Please select a valid .apk file."
        return 1
    fi

    show_info "Installing '$apk_path' on device '$SELECTED_DEVICE'..."
    local output=$("$ADB_PATH" -s "$SELECTED_DEVICE" install "$apk_path" 2>&1)
    if [[ $? -eq 0 ]]; then
        show_info "APK installed successfully!\n\n$output"
    else
        show_error "Error: Failed to install APK.\n\n$output"
    fi
}

main_menu() {
    while true; do
        local choice=$("$GUI_TOOL" --list --title="ADB File Transfer" --text="Select an action for device: $SELECTED_DEVICE" \
            --column="Option" --column="Description" \
            "1" "Push (PC to Android)" \
            "2" "Pull (Android to PC)" \
            "3" "Install APK" \
            "4" "Exit")

        case "$choice" in
            1)
                perform_push
                ;;
            2)
                perform_pull
                ;;
            3)
                install_apk
                ;;
            4)
                if show_question "Are you sure you want to exit?"; then
                #    show_info "Exiting script. Goodbye!"
                    exit 0
                fi
                ;;
            *)
                if [[ -z "$choice" ]]; then # Dialog cancelled
                    if show_question "Are you sure you want to exit?"; then
                    #    show_info "Exiting script. Goodbye!"
                        exit 0
                    fi
                else
                    show_error "Invalid option selected: '$choice'. Please choose a valid number."
                fi
               ;;
        esac
    done
}

# --- Main Execution ---
check_adb
select_device # Select device initially

main_menu
