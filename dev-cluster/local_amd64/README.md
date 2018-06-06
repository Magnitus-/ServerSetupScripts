# Overview

This is a multi virtual machines cluster environment to run locally, using libvirt and kvm.

Currently, the environment is hardcoded to generate 3 masters, 3 workers and a load balancer.

# VM Specs

The CPU architecture of the vm will match you're machine's (presumably amd64, hence the name of the environment's directory). Note that the playbooks in this project are supported for an amd64 and arm64 architectures (and the arm64 architecture is untested, that will be next)

By default, the vms will have 4GB of disk space (a big chunk of which will be used by the OS and k8 dependencies) and 4 vcpus (meaning they can use up to 4 cores as needed).

Additionally, the masters will use 2GB of RAM, the workers will use 4 GB of RAM and the load balancer will use 1 GB of RAM. This is 19GB of RAM in total for the cluster which is probably ok if you have a computer with 64+ GB of RAM, but might be pushing it otherwise.

Fortunately, all of the above are customizable by setting the following environment variables in your shell prior to running the scripts:

```
#Assigning 6 GB for disk space
export DISK_SIZE=6
#Letting vms use up to 8 cores as needed
export VIRTUAL_CPUS=8
#Workers will use up to 8 GB of RAM
export WORKER_RAM=8G
#masters will use up to 1 GB of RAM
export MASTER_RAM=1G
#Load balancer will use up to 1GB of RAM
export LBL_RAM=1G
```

Note that when I tried running the playbooks on vms with 2GB of disk space, I ran out of disk (keeping in mind that Debian was already taking a big chunk of that space) so I wouldn't set the disk space too much below 4 GB. 3 GB is probably pushing it.

For the RAM, I recall reading in a guide that recommended at least 1 GB RAM on k8 nodes, so you might get away with assigning as little as 1GB RAM to your workers and masters, lowering your cluster's RAM quota to 7GB.

# Network Specs

The network used by the vm has the following characteristics:
- Interface: k80
- IPs: 192.168.80.0/24 (range: 192.168.80.2-192.168.80.254, 253 assignable IPs)
- NAT Fowarding Mode: The VMs can access the internet, but don't have a referable IP to connect to outside your local machine

You can modify any of those settings prior to running the script by modifying the **network-host.xml** file.

# Usage

Run the following to generate the network, template image and cluster:

```
./setup.sh
```

After having generated your first cluster with **setup.sh**, you can also do the following...

Delete the cluster (the network and template image will remain):

```
./cleanup_cluster.sh
```

Creater a new cluster (assuming you ran the **setup.sh** script before to generate the network and template image):

```
./generate_cluster.sh
```

Shutdown the machines in the current cluster:

```
./shutdown_cluster.sh
```

Start the machines in the current cluster:

```
./start.sh
```

# Artifacts

Each time you create a new cluster, a new **inventory** file will be generated and you can run your playbooks on it. The inventory containers the ssh password, so you don't need to specify a ssh key when you run your playbook.

# SSH

Currently, you can ssh to your vms using the username **debian** and the password **i_am_a_strong_password_i_think**.

Adding an ssh key and customizable password to the environment is in the plans, but is not the foremost priority given that access to the environment is very restricted beyond your host machine.

# Cleaning Up Everything

There are some scripts to delete the vm cluster of machine, but not to delete the network or template image.

If you really want to cleanup everything (note that if you do, you'll have to run the **setup.sh** script again next time you want to use this environment), type the following:

```
./cleanup_cluster.sh
virsh undefine k8_vm_template
rm -f ./disks/k8_template.img
virsh net-destroy k8-host
virsh net-undefine k8-host
```