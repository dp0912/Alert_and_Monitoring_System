#!/bin/bash
# Data Collection Script
# Reads sensor data from the Arduino via Serial communication and logs it to a file.

# Serial port for Arduino (update based on your system)
SERIAL_PORT="/dev/cu.usbmodemXXXX"  # Replace with your actual Serial port
DATA_LOG="data.log"                 # File to store valid sensor data

# Cleanup function to gracefully close Serial port connection
cleanup() {
    echo "Cleaning up..."
    exec 3>&-  # Close the file descriptor
    exit 0
}

# Trap signals (e.g., Ctrl+C) to ensure cleanup is executed
trap cleanup SIGINT SIGTERM

# Verify that the Serial port exists before proceeding
if [[ ! -e "$SERIAL_PORT" ]]; then
    echo "Error: Serial port $SERIAL_PORT not found."
    exit 1
fi

# Function to continuously read and log data from Arduino
log_data() {
    echo "Listening for Arduino data on $SERIAL_PORT..."
    exec 3<"$SERIAL_PORT"  # Open the Serial port for reading

    while true; do
        if read -r line <&3; then
            echo "Received: $line"  # Debugging: Print received data
            # Check if the received data matches the expected format
            if [[ $line =~ ^LDR=.* ]]; then
                echo "$line" >> "$DATA_LOG"  # Log valid data to file
            else
                echo "Warning: Malformed data: $line" >> error.log  # Log invalid data
            fi
        else
            echo "Warning: Failed to read from Serial port. Retrying..." >> error.log
            sleep 1  # Retry after 1 second
        fi
    done
}

# Start logging data
log_data
