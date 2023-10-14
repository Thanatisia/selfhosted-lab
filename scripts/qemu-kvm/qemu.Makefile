# QEMU/KVM Virtual Machine Makefile

## Ingredients/Materials/Variables
DISK_DRIVE_FORMAT ?= qcow2
DISK_DRIVE_PATH ?= /path/to/qcow/file
DISK_DRIVE_FILE ?= image.qcow
DISK_DRIVE_SIZE ?= 51200M
ISO_IMAGE_PATH ?= /path/to/ISO/image/file
ISO_IMAGE_FILE ?= image.iso
VM_ARCHITECTURE ?= x86_64
VM_NAME ?= virtual-machine-name
VM_MEMORY ?= 1024
VM_DRIVE_MOUNT_POSITION ?= a
VM_NETWORK_OPTIONS ?= 
VM_OPTIONS ?= -daemonize
VM_PID ?= 
VNC_SERVER_IP ?= your-server-ip
VNC_SERVER_PORT ?= 5900
VNC_SERVER_DISPLAY_MONITOR ?= 0
WEBSOCKET_SERVER ?= websockify
WEBSOCKET_SERVER_PORT ?= 6080
WEB_VNC_CLIENT_PATH ?= /usr/lib
WEB_VNC_CLIENT_NAME ?= novnc
WEB_VNC_CLIENT_OPTIONS ?= -D

.DEFAULT_GOAL := help
.PHONY := help setup
SHELL := /bin/bash

## Recipe/Target
help:
	## Display Help options and message
	@echo -e "[Variables]"
	@echo -e "DISK_DRIVE_FORMAT : ${DISK_DRIVE_FORMAT}"
	@echo -e "DISK_DRIVE_PATH : ${DISK_DRIVE_PATH}"
	@echo -e "DISK_DRIVE_FILE : ${DISK_DRIVE_FILE}"
	@echo -e "DISK_DRIVE_SIZE : ${DISK_DRIVE_SIZE}"
	@echo -e "ISO_IMAGE_PATH : ${ISO_IMAGE_PATH}"
	@echo -e "ISO_IMAGE_FILE : ${ISO_IMAGE_FILE}"
	@echo -e "VM_ARCHITECTURE : ${VM_ARCHITECTURE}"
	@echo -e "VM_NAME : ${VM_NAME}"
	@echo -e "VM_MEMORY : ${VM_MEMORY}"
	@echo -e "VM_DRIVE_MOUNT_POSITION : ${VM_DRIVE_MOUNT_POSITION}"
	@echo -e "VM_NETWORK_OPTIONS : ${VM_NETWORK_OPTIONS}"
	@echo -e "VM_OPTIONS : ${VM_OPTIONS}"
	@echo -e "VM_PID : ${VM_PID}"
	@echo -e "VNC_SERVER_IP : ${VNC_SERVER_IP}"
	@echo -e "VNC_SERVER_PORT : ${VNC_SERVER_PORT}"
	@echo -e "VNC_SERVER_DISPLAY_MONITOR : ${VNC_SERVER_DISPLAY_MONITOR}"
	@echo -e "WEBSOCKET_SERVER : ${WEBSOCKET_SERVER}"
	@echo -e "WEBSOCKET_SERVER_PORT : ${WEBSOCKET_SERVER_PORT}"
	@echo -e "WEB_VNC_CLIENT_PATH : ${WEB_VNC_CLIENT_PATH}"
	@echo -e "WEB_VNC_CLIENT_NAME : ${WEB_VNC_CLIENT_NAME}"
	@echo -e "WEB_VNC_CLIENT_OPTIONS : ${WEB_VNC_CLIENT_OPTIONS}"

	@echo -e ""

	@echo -e "[Targets]"
	@echo -e "help  : Display this help message"
	@echo -e "setup : Perform Pre-Requsitie setup checks"
	@echo -e "vm-list : Find and List Virtual Machine processes"
	@echo -e "vm-kill : Kill a specific Virtual Machine Process ID"
	@echo -e "create-drive : Create a new qcow2 disk drive"
	@echo -e "startup-installer : Startup the installer virtual machine as a daemon (Background process/service)"
	@echo -e "vm : Startup the primary/main virtual machine with disk drive as a daemon (Background process/service)"
	@echo -e "vnc-client : Startup the WebSockify server and Web/Browser-based VNC Client"

setup:
	## Perform Pre-Requisite setup checks

vm-list:
	## Find and List Virtual Machine processes
	@ps -ef | grep qemu-system-${VM_ARCHITECTURE}

vm-kill:
	## Kill a specific Virtual Machine Process ID
	@kill ${VM_PID}

create-drive:
	## Create a new QCOW2 drive
	qemu-img create -f ${DISK_DRIVE_FORMAT} ${DISK_DRIVE_PATH}/${DISK_DRIVE_FILE} ${DISK_DRIVE_SIZE}

startup-installer:
	## Startup Operating System Installer Virtual Machine
	qemu-system-${VM_ARCHITECTURE} -name ${VM_NAME} -hd${VM_DRIVE_MOUNT_POSITION} ${DISK_DRIVE_PATH}/${DISK_DRIVE_FILE} -cdrom ${ISO_IMAGE_PATH}/${ISO_IMAGE_FILE} -vnc ${VNC_SERVER_IP}:${VNC_SERVER_DISPLAY_MONITOR} -m ${VM_MEMORY} ${VM_OPTIONS}

vm:
	## Startup a general installed Virtual Machine as a daemon (Background) using VNC as display output
	qemu-system-${VM_ARCHITECTURE} -name ${VM_NAME} -hd${VM_DRIVE_MOUNT_POSITION} ${DISK_DRIVE_PATH}/${DISK_DRIVE_FILE} -vnc ${VNC_SERVER_IP}:${VNC_SERVER_DISPLAY_MONITOR} -m ${VM_MEMORY} ${VM_NETWORK_OPTIONS} ${VM_OPTIONS}

vnc-client:
	## Startup Web/Browser-based VNC client
	websockify ${WEB_VNC_CLIENT_OPTIONS} --web=${WEB_VNC_CLIENT_PATH}/${WEB_VNC_CLIENT_NAME} ${WEBSOCKET_SERVER_PORT} ${VNC_SERVER_IP}:${VNC_SERVER_PORT}


