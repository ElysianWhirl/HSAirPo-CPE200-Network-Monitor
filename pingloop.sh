#!/bin/ash

# Define the target hosts to ping
target1="your_targer_host"
target2="your_targer_host"

# Define the interval between pings in seconds
interval=5

# Loop indefinitely
while :
do
    # Get the IP address of the usb0 interface
    usb0_ip=$(ifconfig usb0 | grep 'inet addr' | awk '{print $2}' | cut -d ':' -f 2)

    # Perform the ping for each target sequentially
    ping_result_target1=$(ping -c 1 -W 1 $target1)
    ping_result_target2=$(ping -c 1 -W 1 $target2)

    # Extract TTL for target1
    ttl_target1=$(echo "$ping_result_target1" | grep -o "ttl=[0-9]*" | cut -d '=' -f 2)

    # Extract TTL for target2
    ttl_target2=$(echo "$ping_result_target2" | grep -o "ttl=[0-9]*" | cut -d '=' -f 2)

    # Extract RTT for target1
    rtt_target1=$(echo "$ping_result_target1" | awk -F '/' 'END {print $5}')

    # Extract RTT for target2
    rtt_target2=$(echo "$ping_result_target2" | awk -F '/' 'END {print $5}')

    # Check if ping to target1 was successful
    if echo "$ping_result_target1" | grep -q " 0% packet loss"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') USB0 IP: $usb0_ip Ping to $target1 OK - TTL: $ttl_target1 - RTT: $rtt_target1 ms"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') USB0 IP: $usb0_ip Ping to $target1 failed"
    fi

    # Check if ping to target2 was successful
    if echo "$ping_result_target2" | grep -q " 0% packet loss"; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') USB0 IP: $usb0_ip Ping to $target2 OK - TTL: $ttl_target2 - RTT: $rtt_target2 ms"
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') USB0 IP: $usb0_ip Ping to $target2 failed"
    fi

    # Wait for the specified interval before pinging again
    sleep $interval
done
