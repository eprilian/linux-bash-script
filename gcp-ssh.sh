#ssh bash script for gcp instance
#!/bin/bash
# Function to prompt for input
get_input() {
    read -p "$1" input
    echo "$input"
}

# Get SSH key path
#ssh_key=$(get_input "Enter the path to your SSH key (ex: /home/noname/key-ssh): ") #use when you input manually location of ssh key
ssh_key=$".ssh/gcp-vm-dev"

# Get username
username=$(get_input "Enter your SSH username (ex: noname, epri): ")

# Get IP address
ip_address=$(get_input "Enter the IP address of the VM (ex: 34.134.14.93, 104.154.32.61): ")

# Attempt to SSH into the VM
echo "Connecting to $ip_address as $username using key $ssh_key..."
ssh -i "$ssh_key" "$username@$ip_address"

# Check if the SSH command was successful
if [ $? -eq 0 ]; then
    echo "Connection successful!"
else
    echo "Connection failed!"
fi

#ssh -i ./ssh/gcp-vm-dev epri@34.142.147.69
