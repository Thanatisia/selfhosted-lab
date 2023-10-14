#!/bin/env bash
: "
Autostart Virtual Machines
"
## Initialize Variables
makefile_Path=/full/path/to/qemu/Makefile/folder
makefile_File=qemu.Makefile
makefile_Exec=${makefile_Path}/${makefile_File}
config_Path=/full/path/to/configuration/files

generate_Template()
{
    : "
    Generate a standard template project filesystem structure
    "
    # Initialize Variables
    config_File="template.sh"

    # Source defaults
    reset_Defaults

    # Create folder
    ## Check if folder exists
    if [[ ! -d $config_Path ]]; then
        ## Folder does not exists
        mkdir -p "$config_Path"
    else
        echo -e "Configurations folder $config_Path already exists."
    fi

    echo -e ""

    ## Check if configuration file exists
    if [[ ! -f $config_Path/$config_File ]]; then
        echo -e "Writing configuration to [$config_Path/$config_File]"

        ## Write template to configuration file
        msg="$(cat <<EOF
## System
vm_arch="$vm_arch"
vm_name="$vm_name"
vm_drive_position="$vm_drive_position"
vm_drive_path="$vm_drive_path"
vm_drive_file="$vm_drive_file"
vm_memory="$vm_memory"
vm_network="$vm_network"
vm_options="$vm_options" 
vnc_server_ip="$vnc_server_ip"
vnc_server_display_monitor="$vnc_server_display_monitor"
vnc_server_Port="$vnc_server_Port"

## WebSocket
vnc_web_client=$vnc_web_client
websocket_Exec="$websocket_Exec" # Websocket Executable
websocket_server_Port="$websocket_server_Port"
websocket_Opts="$websocket_Opts" # Websocket Options
EOF
)"
        echo -e "$msg" | tee -a "$config_Path/$config_File"
    else
        echo -e "Template file [$config_Path/$config_File] exists."
    fi
}

reset_Defaults()
{
    : "
    Get default variable values
    "
    ## System
    vm_arch="x86_64"
    vm_name="your-vm-name"
    vm_drive_position="a"
    vm_drive_path="/full/path/to/disks/"
    vm_drive_file="file.qcow"
    vm_memory="8G"
    vm_network="-net nic -net bridge,br=br0 -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22" # -device e1000,netdev=net0
    vm_options="-daemonize -cpu host -enable-kvm -machine accel=kvm -device ich9-intel-hda" 
    vnc_server_ip="192.168.1.253"
    vnc_server_display_monitor="0"
    vnc_server_Port="5900"

    ## WebSocket
    vnc_web_client=/usr/share/novnc
    websocket_Exec="websockify" # Websocket Executable
    websocket_server_Port="6080"
    websocket_Opts="-D --web=${vnc_web_client} ${websocket_server_Port} ${vnc_server_ip}:${vnc_server_Port}" # Websocket Options
}

source_cfg()
{
    : "
    Source target configuration file
    "
    # Initialize Variables
    id="$1"
    config_file_Type="sh"

    ## Check if configuration file exists
    if [[ -f $config_Path/$id.$config_file_Type ]]; then
        # File exists
        source $config_Path/$id.$config_file_Type
    else
        # File does not exists
        echo -e "Configuration File [$config_Path/$id.$config_file_Type] does not exists."
        exit 1
    fi
}

start_vm()
{
    : "
    Start VM according to ID
    "
    action="$1"

    # Perform default value validation
    case "$action" in
        "start")
            # Keyword: start
            action="vm"
            ;;
        "vm-kill")
            # Kill VM = required Process ID
            # List all process IDs
            make -f ${makefile_Exec} vm-list

    	    # Check if environment variable 'VM_PID' is specified
	        if [[ "$VM_PID" != "" ]]; then
                # VM_PID is specified
                vm_pid="$VM_PID"
            else
                # VM_PID is not specified
                # Get Process ID to kill
                read -p "Please enter the Process ID of the Virtual Machine [$vm_name]: " vm_pid
            fi
            ;;
    esac

    # Begin making the Virtual Machine
    make -f ${makefile_Exec} VM_ARCHITECTURE=${vm_arch} VM_NAME=${vm_name} VM_MOUNT_DRIVE_POSITION=${vm_drive_position} VM_MEMORY=${vm_memory} DISK_DRIVE_PATH=${vm_drive_path} DISK_DRIVE_FILE=${vm_drive_file} VNC_SERVER_IP=${vnc_server_ip} VNC_SERVER_DISPLAY_MONITOR=${vnc_server_display_monitor} VM_OPTIONS="${vm_options}" VM_NETWORK_OPTIONS="${vm_network}" VM_PID="${vm_pid}" $action
}

start_websocket_server()
{
    : "
    Startup the WebSocket server and the Web/Browser-based VNC client
    "
    vnc_web_client=/home/asura/Desktop/repositories/git/novnc
    vnc_server_IP="$1"
    vnc_server_Port="${2:-5900}"
    websocket_Exec="websockify" # Websocket Executable
    websocket_server_Port="${3:-6080}"
    websocket_Opts="-D --web=${vnc_web_client} ${websocket_server_Port} ${vnc_server_IP}:${vnc_server_Port}" # Websocket Options

    # Startup WebSocket server and the Web/Browser-based VNC client
    ${websocket_Exec} ${websocket_Opts}
}

main()
{
    argv=("$@")
    argc="${#argv[@]}"

    # Check if argument is provided
    if [[ "$argc" -gt 0 ]]; then
        for i in "${!argv[@]}"; do
            # Loop through indexes and perform the actions accordingly
            curr_arg="${argv[$i]}" ## Get Action

            case "$curr_arg" in
                "start" | "vm")
                    # Start VM and WebSocket server
                    ## Get subargument index/position = Index of virtual machine
                    next_i=$((i+1))
                    ## Get subargument value = Action
                    next_val="${argv[$next_i]}"

                    ## Process subargument
                    ### Check if value is empty
                    if [[ "$next_val" != "" ]]; then
                        # Not empty
                        echo -e "Target index [$next_i] specified: $next_val"

                        ## Unset subargument from list remove it from the list
                        unset argv[$next_i]

                        # Source configurations according to specified ID
                        source_cfg "$next_val"

                        ### Start VM according to index specs
                        # start_vm "$i" "${curr_arg}"
                        start_vm "${curr_arg}"

                        # Start WebSocket server and VNC client incrementally
                        # start_websocket_server ${vnc_server_ip} "$((5900 + $vnc_server_display_monitor))" "$((6080 + $vnc_server_display_monitor))"
                        start_websocket_server ${vnc_server_ip} "${vnc_server_Port}" "${websocket_server_Port}"
                    else
                        # Empty
                        echo -e "No target index specified."
                    fi
                    ;;
                "check" | "vm-check")
                    # Check if VM is up by checking if process is found
		    
                    ## Get subargument index/position
                    next_i=$((i+1))
                    ## Get subargument value
                    next_val="${argv[$next_i]}"

                    ## Process subargument
                    ### Check if value is empty
                    if [[ "$next_val" != "" ]]; then
                        ## Not Empty
                        ## Unset subargument from list remove it from the list
                        unset argv[$next_i]

                        ## Set vm name
                        vm_name="$next_val"
                    else
                        ## Get user input of the target Virtual Machine name '-name vm-name'
                        read -p "Please enter the name of the target Virtual Machine: " vm_name
                    fi
            
                    ## Get result
                    lines=`ps -ef | grep "name $vm_name"`

                    ## Get number of lines
                    number_of_lines=`ps -ef | grep "name $vm_name" | wc -l`

                    ## Process and validate number of lines
                    if [[ "$number_of_lines" -gt "1" ]]; then
                        # Greater than 1
                        # Virtual Machine Exists
                        # Lines 0 and 1 is the validation command itself and the Makefile, with 1 comment
                        echo -e "Process exists."

                        echo -e ""

                        ## Calculate Countable lines
                        countable_lines=$((number_of_lines - 1))
                            
                        # Get Process ID
                        echo -e "Countable Lines: $countable_lines"
                        echo -e "$lines"
                    else
                        # Does not exist
                        echo -e "Virtual Machine [$vm_name] does not exist."
                    fi
                    ;;
                "kill" | "vm-kill")
                    # Kill VM = required Process ID

                    # Check if environment variable 'VM_PID' is specified
                    if [[ "$VM_PID" != "" ]]; then
                        # VM_PID is specified
                        vm_pid="$VM_PID"
                    else
                        # VM_PID is not specified

                        ## List all process IDs
                        make -f ${makefile_Exec} vm-list

                        ## Get Process ID to kill
                        read -p "Please enter the Process ID of the Virtual Machine [$i]: " vm_pid
                    fi

                    # Kill process
                    make -f ${makefile_Exec} VM_PID=${vm_pid} vm-kill
                    ;;
                "list" | "vm-list")
                    # List all process IDs
                    make -f ${makefile_Exec} vm-list
                    ;;
                "generate-defaults")
                    # Generate default template
                    generate_Template
                    ;;
                "help")
                    ## Display help menu
                    msg="$(cat <<EOF
[Synopsis/Syntax]
(sudo) autostart [action] {options} <arguments>

[Options]
- Positionals
    - actions
	+ start | vm  [vm-configuration-id | subactions (vm-kill)] : Start VM and WebSocket server
        + check | vm-check [target-vm-name] : Check if VM is up by checking if process is found
        + kill  | vm-kill   : Kill a specified Virtual Machine Process ID
        + list  | vm-list   : List all process IDs
        + generate-defaults : Generate template project filesystem structure
        + help : Display this help message
- Optionals

[Usage]
- To start a Virtual Machine configuration
    (sudo) autostart.sh start 0
- To start multiple Virtual Machine configurations
    + Just append and repeat the 'start [configuration-file-name]
    (sudo) autostart.sh start [configuration-file-name-1] start [configuration-file-name-2] ...
- To list all Virtual Machines
    autostart.sh vm-list
- To kill a Virtual Machine
    (sudo) autostart.sh vm-kill
- To kill a Virtual Machine using Environment Variables
    + Use the 'VM_PID' environment variable
    (sudo) VM_PID=[vm-process-ID] autostart.sh vm-kill

[Environment Variables]
- VM_PID : Explicitly specify the Process ID (PID) of the Virtual Machine; You can get it either by using 'ps -ea | grep qemu-system-[ARCH]' or 'make -f qemu.Makefile vm-list'
    + Specify this before running 'autostart vm-kill' to kill the process without any user input
EOF
)"
                    echo -e "$msg"
                    ;;
                *)
                    # Invalid Option
                    # echo -e "Invalid option: $curr_arg"
                    ;;
            esac

            # New line
            echo -e ""
        done

        # start_vm "1" "${argv[0]}"
        # start_websocket_server "192.168.1.25" "5900" "6080"

        # echo -e ""

        # start_vm "2" "${argv[1]}"
        # start_websocket_server "192.168.1.25" "5901" "6081"
    else
        # Not provided
        echo -e "No argument provided."
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
