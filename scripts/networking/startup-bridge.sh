#!/bin/env bash
: "
Startup bridge
"

# Initialize Variables
host_ipv4_Address="${1:-$HOST_IPV4_ADDRESS}"
host_subnet_Prefix="${2:-$HOST_SUBNET_PREFIX}"
host_ipv4_default_Gateway="${3:-$HOST_DEFAULT_GATEWAY}"
host_interface_Name="${4:-$HOST_NETWORK_INTERFACE}"
bridge_interface_Name="${5:-$BRIDGE_NETWORK_INTERFACE}"

host_ipv4_Address="192.168.1.X"
host_subnet_Prefix="24"
host_ipv4_default_Gateway="192.168.1.254"
host_interface_Name="enp1s0"
bridge_interface_Name="br0"

# Check if user is root
if [[ "$SUDO_USER" != "" ]]; then
    # Superuser
    echo -e "Starting up bridged network..."

    # Perform bridge creation
    ip link add name $bridge_interface_Name type bridge

    # Set state of bridge to up
    ip link set dev $bridge_interface_Name up

    # Set IP address of the bridge network interface to the IP address of the NIC host network interface
    ip address add $host_ipv4_Address/$host_subnet_Prefix dev $bridge_interface_Name

    # Append new route to bridge network interface
    ip route append default via $host_ipv4_default_Gateway dev $bridge_interface_Name

    # Attach the NIC host network interface to the bridge network interface AND remove the IPv4 address from the host network interface so that network connectivity will be retained
    ip link set $host_interface_Name master $bridge_interface_Name && \
        ip address del $host_ipv4_Address/$host_subnet_Prefix dev $host_interface_Name

    # Show bridge
    brctl show && \
	    ip a s | grep $bridge_interface_Name
else
    # Not SuperUser
    echo -e "Please run this script as superuser"
fi
