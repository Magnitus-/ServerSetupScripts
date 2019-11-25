import os

def get_masters_count():
    return os.environ.get('MASTERS_COUNT')

def get_inventory_destination():
    return os.environ.get('INVENTORY_DESTINATION')

def get_kubespray_destination():
    return os.environ.get('KUBESPRAY_DESTINATION')

def get_ansible_user():
    return os.environ.get('ANSIBLE_USER')

def get_private_ssh_key():
    return os.environ.get('PRIVATE_SSH_KEY')

def get_cluster_ips():
    return os.environ.get('CLUSTER_IPS')