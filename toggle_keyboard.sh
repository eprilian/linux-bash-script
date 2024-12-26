#toggle internal keyboard on or off in linu
#!/bin/bash

# Replace with your internal keyboard device name
INTERNAL_KEYBOARD="AT Translated Set 2 keyboard"

# Get the device ID based on the name
DEVICE_ID=$(xinput list --id-only "$INTERNAL_KEYBOARD")

# Start a loop to keep the script running until the user decides to exit
while true; do
    # Use Zenity for GUI dialog
    ACTION=$(zenity --list --radiolist --column="Pick" --column="Action" \
        TRUE "Enable Keyboard" \
        FALSE "Disable Keyboard" \
        --title="Turn On / Off Internal Keyboard" \
        --width=300 --height=200 \
        --cancel-label="Exit")

    # If the user clicks the "Exit" button or closes the window, break out of the loop
    if [ $? -ne 0 ]; then
#        zenity --info --text="Exit program." --title="Exiting"
        break
    fi

    # Check which option was selected
    if [ "$ACTION" == "Enable Keyboard" ]; then
        # Enable the internal keyboard
        xinput enable "$DEVICE_ID"
        zenity --info --text="Internal keyboard enabled!" --title="Success"
    elif [ "$ACTION" == "Disable Keyboard" ]; then
        # Disable the internal keyboard
        xinput disable "$DEVICE_ID"
        zenity --info --text="Internal keyboard disabled!" --title="Success"
    fi
done

#main_menu & disown
