# Overview

This is a multi virtual machines cluster environment to run locally, using libvirt and kvm.

Currently, the environment is hardcoded to generate 3 masters, 3 workers and a load balancer.

# Dependencies

You need libvirt and kvm installed (should be able to run the virsh, virt-install and virt-clone commands).

The **install_dependencies_ubuntu_18.04.sh** installs all the requisite dependencies for that version of Ubuntu. Note that you'll have to logout after the installation for the right permissions to take effect.

# Important Note

I couldn't get the kubernetes playbooks to work on the arm64 emulated qemu environment. The underlying cause of the failure is unknown (the k8 api proved to be unstable and kept crashing). It could have been quirks with my installation of qemu or edge cases triggered by hardware emulation or the abysmal performance it caused.

Ultimately, for arm64, I got the playbooks to work on a Scaleway cluster of arm64 machines which validates the arm64 use-case.

Furthermore, the more usable amd64 setup with kvm works and has been tested multiple times at this point.

Given that the only reason for the arm64 emulated environment was to test the installation done by the kubernetes playbooks (arm64 emulation performance was too poor for me to consider it usable beyond that use-case), I do not intent to investigate the problem further.

Additional note: Months ago, a cluster of Rasberry Pis running HypriotOS ended up failing with the same failure as the local vms. arm64 compatibility seems to be a case-by-case thing.

# VM Specs

By default, the vms run on kvm using the host's cpu architecture (amd64 is assumed). Alternatively, the arm64 cpu architecture can be emulated via qemu. The **CPU_ARCHITECTURE** environment variable controls this (**adm64** for amd64/kvm, **arm64** for arm64/qemu). Note that arm64 cpu emulation on qemu will run considerable slower than amd64 with cpu passthrough on kvm. It's suitable if you just want to test the installer on that architecture (my use case), but not if you intent to do serious work.

By default, the vms will have 4GB of disk space (a big chunk of which will be used by the OS and k8 dependencies) and 4 vcpus (meaning they can use up to 4 cores as needed).

Additionally, the masters will use 2GB of RAM, the workers will use 4 GB of RAM and the load balancer will use 2 GB of RAM. This is 20GB of RAM in total for the cluster which is probably ok if you have a computer with 64+ GB of RAM, but might be pushing it otherwise.

Fortunately, all of the above are customizable by setting the following environment variables in your shell prior to running the scripts:

```
#Setting vm cpu to emulated arm64
export CPU_ARCHITECTURE=arm64
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

Delete the cluster:

```
./destroy.sh
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

The generated **id_rsa** file is a key you can use to ssh into any of the machines as the user **admin**. That user has root privileges with sudo.