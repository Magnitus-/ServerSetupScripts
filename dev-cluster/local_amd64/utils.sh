
function get_domain_ip {
    local VM_IP=$(virsh domifaddr $1 | head -n3 | tail -n1 | tr -s ' ' | cut -d ' ' -f5 | sed -En "s|(.*)/.+|\1|p")
    while [ -z "$VM_IP" ]; do
        sleep 1;
        local VM_IP=$(virsh domifaddr $1 | head -n3 | tail -n1 | tr -s ' ' | cut -d ' ' -f5 | sed -En "s|(.*)/.+|\1|p")
    done
    echo $VM_IP
} 

function get_domain_mac {
    local MAC_ADDRESS=$(virsh domiflist $1 | head -n3 | tail -n1 | tr -s ' ' | cut -d ' ' -f5)
    while [ -z "$MAC_ADDRESS" ]; do
        sleep 1;
        local MAC_ADDRESS=$(virsh domiflist $1 | head -n3 | tail -n1 | tr -s ' ' | cut -d ' ' -f5)
    done
    echo $MAC_ADDRESS
} 