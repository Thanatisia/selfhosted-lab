: "
QEMU/KVM Support CLI Utility
"

select_Entry()
{
    : "
    Get Virtual Machine proceess ID (PID) number
    "
    # Select and get Virtual Machine ID
    vm_selected_Entry=$(./autostart.sh vm-list | fzf)

    # Return
    echo -e "$vm_selected_Entry"
}

get_process_ID()
{
    : "
    Cut and get the Process ID
    "
    vm_selected_Entry="$1"

    # Cut 
    vm_pid="$(echo $vm_selected_Entry | cut -d ' ' -f2)"

    # Return
    echo -e $vm_pid
}

select_and_get_PID()
{
    : "
    Select a Process ID and kill
    "
    # Initialize Variables
    res=""
    vm_selected_Entry=`select_Entry`
    vm_pid=`get_process_ID "$vm_selected_Entry"`

    # Accumulate results into entry
    res="$vm_selected_Entry $vm_pid"

    # Output
    echo -e "$vm_pid"
}

vm_kill()
{
    : "
    Select and kill a virtual machine process ID
    "

}

vm_pid="`select_and_get_PID`"
echo -e "Selected Process ID: $vm_pid"

