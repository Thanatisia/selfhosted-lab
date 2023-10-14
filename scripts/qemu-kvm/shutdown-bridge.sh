#!/bin/env bash
: "
Shutdown the bridge network interface
"

# Check if user is root
if [[ "$SUDO_USER" != "" ]]; then
    # Superuser
    echo -e "Disabling and removing bridged network..."

else
    # Not SuperUser
    echo -e "Please run this script as superuser"
fi
