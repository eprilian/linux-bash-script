#easy ssh bash script
#!/bin/bash

# Function to prompt for input
get_input() {
    read -p "$1" input
    echo "$input"
}

# Function to get password with hidden input
get_password() {
    # Disable echo
    stty -echo
    read -p "$1" password
    echo ""
    # Re-enable echo
    stty echo
}

# Get SSH key path (optional)
ssh_key=$(get_input "Enter the path to your SSH key (leave empty if using password): ")

# Get username
username=$(get_input "Enter your SSH username: ")

# Get IP address
ip_address=$(get_input "Enter the IP address of the VM: ")

# Get password (if no SSH key is provided)
if [ -z "$ssh_key" ]; then
    get_password "Enter your SSH password: "
fi

# Attempt to SSH into the VM
if [ -n "$ssh_key" ]; then
    echo "Connecting to $ip_address as $username using key $ssh_key..."
    ssh -i "$ssh_key" "$username@$ip_address"
else
    echo "Connecting to $ip_address as $username with password..."
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@$ip_address"
fi

# Check if the SSH command was successful
if [ $? -eq 0 ]; then
    echo "Connection successful!"
else
    echo "Connection failed!"
fi
