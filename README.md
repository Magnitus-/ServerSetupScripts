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

Same steps as the single server environment, but under the ```dev-cluster/aws``` directory instead.

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

Similar to the single server, but under the ```dev-cluster/aws``` directory. Also note that the **inventory** file will contain a list of several machines and you can ssh into any one of them.

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
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_cluster_single_master.yml --private-key=dev-cluster/key -u admin -i test-cluster/aws/inventory
```

Note that for this playbook to work well, you need to have setup a cluster with a single master and at least one worker.

### k8 cluster (ha)

Creates a cluster of k8 masters and k8 workers using the existing playbooks. 

#### Usage 

From the top-level directory, type:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_cluster_ha.yml --private-key=dev-cluster/key -u admin -i test-cluster/aws/inventory
```

Some customizations are possible by passing the following variables to the playbook:
- kubernetes_admin: Specifies a user that will be configured on the machines to run kubectl commands. Defaults to the user you run the playbooks with.
- api_url: Specifics an url (with some sort of load_balancing) that can be used to access the masters' API. Defaults to the load balancer's IP if a load balancer is present in the inventory.
- connection_timeout: Specifies the connection timeout if you are using a load-balancer. Defaults to 3000ms.
- client_timeout: Specifies the frontend response timeout if you are using a load-balancer. Defaults to 3000ms.
- server_timeout: Specifies the backend response timeout if you are using a load-balancer. Defaults to 3000ms.

Additionally, the following variable can be set on hosts in the inventory:
- internal_ip: Specifies an ip for the machine that should be used when connecting to other machines in the k8 cluster. Defaults to the inventory hostname of the machine.

#### Note

The playbook will, optionally, provision a load balancer, although it does not (yet) provide a high availability solution for the load balancing.

If the load balancing part of the script is used, the ip of the first load balancer in the inventory will be used by the k8 cluster for load balancing (making any extra load balancers in the inventory pointless). This is fine for a mock/dev environment, but not suitable for production as it makes the load balancer a single point of failure.

A high availability solution may be obtained by leaving the **load_balancers** inventory empty and doing the following:
- If you are using a cloud provider that provides a load balancing service, setup a load balancer with your cloud provider and pass its url to the playbook via the **api_url** ansible variable
- Use a dynamic dns with failure detection like Consul (at that point, the load balancers become optional). If you opt for this, you can make the consul domain either point to a cluster of load balancers or directly to the masters. You can pass the consul domain to **api_url**.

While I could have provided a direct integration with an aws load balancer in the terraformed test environments, I opted to use a less scalable single haproxy setup even for the tests as I really want this playbook to be able to provide a working environment that is cloud agnostic (otherwise, I'd simply be using Kops and not be bothering with this project).

I will later investigate a consul integration within the playbook to achieve true high availability with no extra steps (at least for internal use within the k8 cluster, some extra steps will realistically be needed to access the master API from the outside).