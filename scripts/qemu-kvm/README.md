# QEMU/KVM qemu-system-[ARCHITECTURE] CLI utilities

## Setup
### Dependencies
+ qemu
+ qemu-system-[ARCHITECTURE]
+ kvm
+ libvirt

### Pre-Requisites
+ Please run the script as sudo
- Generate/Prepare a configuration file in the configuration folder of your choice (specify in autorunner.sh)
    + You can name the configuration file anything, as this contains the specifications of the Virtual Machine you wish to create

## Documentations
### Synopsis/Syntax
- autostart.sh
    ```console
    (sudo) autostart.sh [action] {options} <arguments>
    ```

- To use the Makefile
    + Explicitly specify the Makefile name
    ```console
    make -f qemu.Makefile [recipe]
    ```

### Parameters
- Positionals
    + start | vm [vm-configuration-ID | subactions (vm-kill)] : Start the Virtual Machine and WebSocket server
    + check | vm-check [target-vm-name] : Check if the VM is up by checking if process is found
    + kill  | vm-kill : Kill a specified Virtual Machine Process ID; Checks for the Environment Variable 'VM_PID' for process to kill (Check using vm-list) - will ask user for process to kill if not specified.
    + list  | vm-list : List all process IDs
    + generate-defaults : Generate template project configuration filesystem structure
    + help : Display this help message
    + [makefile-targets] : Specify any targets in qemu.Makefile to passthrough to it
- Optionals

### Makefile recipes
+ create-drive: Create a new QCOW2 drive
+ startup-installer: Startup a Virtual Machine running an Operating System Installer
+ vm : Start Virtual Machine and WebSocket server
+ vm-list : List all process IDs
+ vm-kill : Kill a specified Virtual Machine Process ID; Checks for the Environment Variable 'VM_PID' for process to kill (Check using vm-list) - will ask user for process to kill if not specified.
+ vnc-client: Startup Web/Browser-based VNC client

### Usage
- Display help menu for autostart CLI utility
    ```console
    autostart.sh help
    ```

- To list all Virtual Machines
    ```console
    autostart.sh vm-list
    ```

- To kill a Virtual Machine
    ```console
    (sudo) autostart.sh vm-kill
    ```

- To kill a Virtual Machine using Environment Variables
    + Use the 'VM_PID' Environment Variable
    ```console
    (sudo) VM_PID=[vm-process-id] autostart.sh vm-kill
    ```

- To start a Virtual Machine
    ```console
    (sudo) autostart.sh start [vm-configuration-file-name]
    ```

- To start multiple Virtual Machine configurations
    + Just append and repeat the parameter 'start [vm-configuration-file-name]'
    ```console
    (sudo) autostart.sh start [vm-configuration-file-name-1] start [vm-configuration-file-name-2] ...
    ```


## Wiki

### Configuration Template
- Create a bash shellscript file of any name
    + Note the name, because the name is the ID of the Virtual Machine you wish to start
    ```console
    ## System
    vm_arch="x86_64"
    vm_name="your-vm-name"
    vm_drive_position="a"
    vm_drive_path="/full/path/to/disks/"
    vm_drive_file="file.qcow"
    vm_memory="8G"
    vm_network="-net nic -net bridge,br=br0 -device e1000,netdev=net0 -netdev user,id=net0,hostfwd=tcp::5555-:22"
    vm_options="-daemonize -cpu host -enable-kvm -machine accel=kvm -device ich9-intel-hda" 
    vnc_server_ip="192.168.1.X"
    vnc_server_display_monitor="0"
    vnc_server_Port="5900"

    ## WebSocket
    vnc_web_client=/usr/share/novnc
    websocket_Exec="websockify" # Websocket Executable
    websocket_server_Port="6080"
    websocket_Opts="-D --web=/usr/share/novnc 6080 192.168.1.253:5900" # Websocket Options
    ```

### Environment Variables
- VM_PID : Explicitly specifiy the Process ID (PID) of the Virtual Machine
    + You can get it either by using 'ps -ea | grep qemu-system-[ARCH]' or 'make -f qemu.Makefile vm-list'
    + Specify this before running 'autostart vm-kill' to kill the process without any user input

## Resources

## References

## Remarks
