# Headless Virtual Machine Using QEMU/KVM hypervisor + NoVNC Web/Browser-based VNC Client using Websockify

## Setup
### Dependencies
- Hypervisor
    + QEMU
    + KVM
    + libvirt

### Pre-Requisites
- Prepare the Virtual Machine specifications you want to startup with
- Prepare NoVNC and Websockify

### Implementation Flow and Integration
- Startup Virtual Machine in Headless Mode
    - Using VNC
        + Display Output Method: VNC
        + Display Output Monitor: Port ':1'
        + VNC Server Port Number: '59' + [Display-output-monitor]
        ```console
        qemu-system-[architecture] \
            ## Essentials \
            -name [virtual-machine-name] -cpu [machine-cpu] -memory [ram] -vnc [server-ip-address][display-output-monitor] --enable-kvm \
            ## Optionals \
            -cdrom [disk-image-file (.iso)] -drive file=[virtual-drive (.vhd|qcow2)],format=raw
        ```

- If using VNC for Display Output
    - Startup WebSocket Web/Browser-based VNC Client
        + Web/Browser-based VNC Client: NoVNC
        + Web/Browser-based VNC Client path: /usr/share/novnc
        + WebSocket server: websockify
        + WebSocket UI Port Number: 6080
        - WebSocket Options: 
            + -D | --daemonize : To run as a daemon; background mode
        - Synopsis/Syntax
            ```console
            websockify -D --web=/usr/share/novnc [web-ui-port-number] [server-ip-address]:[port-number]
            ```
        - Snippets and Usage Examples
            - Mapping VNC server in 192.168.1.X running on port 5901 => Websocket port 6080
                ```console
                websockify -D --web=/usr/share/novnc 6080 192.168.1.X:5901
                ```
 
    - To access
        - Open Web browser
            - Type in the Web/Browser-based VNC Client's URL in the address bar
                ```
                http(s)://[server-ip-address]:[web-ui-port-number]/vnc.html
                ```

## Implementations in the real world
+ Proxmox : This is essentially how Proxmox implements their WebUI console using either SPICE/VNC for their headless display output; They use QEMU/KVM for the hypervisor

## Resources

## References

## Remarks