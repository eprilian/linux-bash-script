#!/bin/bash

# Default port
PORT=80

# Prompt user for directory
read -p "Enter the directory to serve: " DIRECTORY

# Check if directory is provided
if [ -z "$DIRECTORY" ]; then
  echo "Error: No directory entered."
  exit 1
fi

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
  echo "Error: Directory '$DIRECTORY' does not exist."
  exit 1
fi

# Start the HTTP server
echo "Starting HTTP server on port $PORT serving directory: $DIRECTORY"
python3 -m http.server $PORT -d "$DIRECTORY"
