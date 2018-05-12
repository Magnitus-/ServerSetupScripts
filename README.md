# Purpose

Scripts to remotely setup hosts via ansible

As I'm mostly using Docker, the requirements are quite minimal.

## Setup Test Environment

You need terraform for this. Note that the test environment is on AWS, so you should not be running it indefinitely.

### Single Server

Go in ```test-server``` and type:

```
terraform apply
```

You'll also need to specify **yes**

To destroy it, you can simply type:

```
terraform destroy
```

### Cluster (3 machines by default)

Same steps as the single server environment, but under the ```test-cluster``` directory instead.

You can overwrite the **workers_count** and **masters_count** variables when setting up your environment (by passing their override values to the **terraform apply** command). The default values are a single master and two workers.

A command overwriting the values (in this case for 3 workers and 3 masters) would go like this:

```
terraform apply -var 'workers_count=3' -var 'masters_count=3'
```

Once you would be done with the above, you would tear down the machines by typing:

```
terraform destroy -var 'workers_count=3' -var 'masters_count=3'
```

## Sshing Into Test environment

### Single Server

Go in ```test-server``` and look at the **inventory** file to get the test server ip.

From there, in the **test-environment** directory, type:

```
ssh -i key admin@<ip of the host>
```

### Cluster

Similar to the single server, but under the ```test-cluster``` directory. Also note that the **inventory** file will contain a list of several machines and you can ssh into any one of them.

## Test Ansible Roles

### Docker

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_docker.yml --private-key=test-server/key -u admin -i test-server/inventory
```

### python-packages

The latest version of the **pip** tool and the **docker** package (version 3.2.1 by default) will be installed.

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_python_packages.yml --private-key=test-server/key -u admin -i test-server/inventory
```

### kubeadm

kubeadm, kubelet and kubectl will be installed. Note that docker is expected to already be installed on the host.

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_kubeadm.yml --private-key=test-server/key -u admin -i test-server/inventory
```

### k8 master

Initialize a k8 master using flannel as the network driver. Note that both docker and kubeadm are expected to already be installed on the host.

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_k8_master.yml --private-key=test-server/key -u admin -i test-server/inventory
```

## Test Ansible Playbooks

### k8 cluster (single master)

Creates a cluster of one k8 master and k8 workers using the existing playbooks.

From the top-level directory, type:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_cluster_single_master.yml --private-key=test-cluster/key -u admin -i test-cluster/inventory
```

Note that for this playbook to work well, you need to have setup a cluster with a single master and at least one worker.

### k8 cluster (ha)

TODO
