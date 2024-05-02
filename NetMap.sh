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
               Version: \e[1;31m1.0\e[0m                                                                                                      
"

echo -e "$banner"

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
    ip_list+=("$ip")
    if ! echo "$sorted_ips" | grep -q "$ip"; then
        echo -e "\e[32m$ip\e[0m" # Print available IPs in green color
    fi
    ((j++))
done

# Identify the network CIDR based on the ip_list
num_ips=${#ip_list[@]}
network_cidr=$(echo "32 - l($num_ips)/l(2)" | bc -l)
network_cidr=$(printf "%.0f" "$network_cidr")
network_ip=$(identify_network_ip $network_cidr "${ip_list[@]}")

gateway=$(sudo netdiscover -P -r "$network_ip/$network_cider" | grep -Ei 'router|gateway|modem|access point|firewall|dhcp|nat|wan|lan|subnet|cisco|tp-link|netgear|d-link|linksys|archer|2900' | awk '{print $1}')
echo -e "\n\e[1mGateway found:\e[0m \e[32m$gateway\e[0m"
echo -e "\n\e[1mConcluded Network CIDR Based On The Results:\e[0m \e[32m$network_ip/$network_cidr\e[0m"
