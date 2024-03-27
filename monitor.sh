#!/bin/ash

# Define the target hosts to ping
target1="your_targer_host"
target2="your_targer_host"
target3="your_targer_host"

# Define the interval between pings in seconds
interval=3

# Number of consecutive failed pings to trigger a reset
consecutive_failures=3

# Function to perform ping
perform_ping() {
    local target="$1"
    local target_name="$2"
    if ping -c 1 -W 1 "$target" >/dev/null; then
        echo "$(date "+%Y-%m-%d %H:%M:%S") - USB0 IP: $usb0_ip: Ping to $target_name OK (Response time: $(ping -c 1 "$target" | awk -F'=' '/time=/ {print $4}' | cut -d " " -f 1) ms)"
        return 0
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S") - USB0 IP: $usb0_ip: Ping to $target_name failed"
        return 1
    fi
}

# Loop indefinitely
while :
do
    # Get current date and time
    current_time=$(date "+%Y-%m-%d %H:%M:%S")

    # Get IP address obtained by usb0 interface
    usb0_ip=$(ip -4 addr show usb0 | awk '/inet / {print $2}' | cut -d "/" -f 1)

    # Initialize failed counts for each target
    failed_count_target1=0
    failed_count_target2=0
    failed_count_target3=0

    # Perform ping for each target
    perform_ping "$target1" "Target 1"
    if [ $? -eq 0 ]; then
        failed_count_target1=0
    else
        failed_count_target1=$((failed_count_target1 + 1))
    fi

    perform_ping "$target2" "Target 2"
    if [ $? -eq 0 ]; then
        failed_count_target2=0
    else
        failed_count_target2=$((failed_count_target2 + 1))
    fi

    perform_ping "$target3" "Target 3"
    if [ $? -eq 0 ]; then
        failed_count_target3=0
    else
        failed_count_target3=$((failed_count_target3 + 1))
    fi

    # Check if all targets encountered consecutive failed pings
    if [ $failed_count_target1 -ge $consecutive_failures ] && [ $failed_count_target2 -ge $consecutive_failures ] && [ $failed_count_target3 -ge $consecutive_failures ]; then
        echo "$current_time - USB0 IP: $usb0_ip: All targets encountered $consecutive_failures consecutive failed pings. Running 4greset.sh..."
        # Run 4greset.sh script
        /usr/bin/4greset.sh
        echo "$current_time - USB0 IP: $usb0_ip: Waiting for 45 seconds before resuming pinging..."
        # Wait for 45 seconds before resuming pinging
        sleep 45
    fi

    # Wait for the specified interval before pinging again
    sleep $interval
done
