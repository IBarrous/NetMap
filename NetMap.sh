#!/bin/bash

banner="
  _   _      _   __  __             
 | \ | |    | | |  \/  |            
 |  \| | ___| |_| \  / | __ _ _ __  
 | . ' |/ _ \ __| |\/| |/ _' | '_ \ 
 | |\  |  __/ |_| |  | | (_| | |_) |
 |_| \_|\___|\__|_|  |_|\__,_| .__/ 
                             | |    
                             |_|             

            by \e[1;31mIsmail Barrous\e[0m
               Version: \e[1;31m2.0\e[0m                                                                                                      
"

echo -e "$banner"

count_ips() {
    awk '{ ips[$1]++ } END { for (ip in ips) print ip, ips[ip] }' -
}

identify_network_ip() {
    local cidr="$1"
    local ip_list=("${@:2}")
    # Extract the network IP address from the first IP address in the list
    local network_ip=$(echo "${ip_list[0]}" | awk -F '.' '{printf "%s.%s.%s.%s", $1, $2, $3, int($4/(2^(32-cidr)))*(2^(32-cidr))}')
    echo "$network_ip"
}

echo -e "\e[1;33mSniffing the network for ARP packets to detect IPs\e[0m"
echo -e "\n\e[1;33mDuration: 5 Minutes\e[0m"

#scans the network for arp packets for 5 minutes

scan_result=$(timeout 5m sudo tcpdump -i eth0 arp 2>/dev/null)

found_ips=$(echo "$scan_result" | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')

# Check if any IP addresses were found
if [ -z "$found_ips" ]; then
    echo "No IP addresses found."
    exit 1
fi

# Count occurrences of each IP address
gateway=$(echo "$found_ips" | count_ips | sort -rn -k2 | head -n1 | awk '{print $1}')
# Print the most repeated IP address

# Sort the found IP addresses in ascending order
sorted_ips=$(echo "$found_ips" | sort -u -V)

# Print the sorted IP addresses
echo -e "\n\e[1mUsed IP addresses:\e[0m"

echo "$sorted_ips"

# Extract the first and last IPs from the sorted list
last_ip=$(echo "$sorted_ips" | tail -n 1)
first_ip=$(echo "$sorted_ips" | head -n 1)
i=$(echo "$last_ip" | awk -F '.' '{print $4}')
j=$(echo "$first_ip" | awk -F '.' '{print $4}')
prefix=$(echo "$last_ip" | awk -F "." '{print $1"."$2"."$3}')

# Initialize a list to store available IP addresses
ip_list=()

echo -e "\n\e[1mAvailable IP addresses:\e[0m"
while [ $j -le $i ]; do
    ip="$prefix.$j"
    if ! echo "$sorted_ips" | grep -q "$ip"; then
    ip_list+=("$ip")
        echo -e "\e[32m$ip\e[0m" # Print available IPs in green color
    fi
    ((j++))
done

# Identify the network CIDR based on the ip_list
num_ips=${#ip_list[@]}
network_cidr=$(echo "32 - l($num_ips)/l(2)" | bc -l)
network_cidr=$(printf "%.0f" "$network_cidr")

network_ip=$(identify_network_ip $network_cidr "${ip_list[@]}")

echo -e "\n\e[1mGateway found:\e[0m \e[32m$gateway\e[0m"

echo -e "\n\e[1mConcluded Network CIDR Based On The Results:\e[0m \e[32m$network_ip/$network_cidr\e[0m"
