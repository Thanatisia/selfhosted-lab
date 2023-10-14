#!/bin/env bash
: "
Startup bridge
"

# Check if user is root
if [[ "$SUDO_USER" != "" ]]; then
    # Superuser
    echo -e "Starting up bridged network..."

else
    # Not SuperUser
    echo -e "Please run this script as superuser"
fi
