# Purpose

Scripts to remotely setup hosts via ansible

As I'm mostly using Docker and Kubernetes, the requirements are not that much.

## Dev Environments

The following dev environments are provdided with the project:

- A single server privisioned on aws via Terraform (debian)
- A cluster comprising a variable number of masters, workers and an optional load balancer provisioned on aws via Terraform (debian)
- A cluster comprising a variable number of masters, workers and an optional load balancer provisioned, all arm64 machines, on Scaleway via Terraform (debian)
- A cluster comprising 3 masters, 3 workers and a load balancer provioned locally via libvirt and kvm/qemu (adm64 supported natively via kvm, arm64 emulated via qemu) (ubuntu bionic)

The single server environment and accompanying documentation can be found in the following directory: **dev-server**

The aws cluster environment and accompanying documentation can be found in the following directory: **dev-cluster/aws**

The libvirt/kvm environnent and accompanying documentation can be found in the following directory: **dev-cluster/local**

## Ansible Roles

Most of the roles in this project are part of a kubernetes setup and are best used as part of the kubernetes playbook.

However, the **docker** and **python-packages** roles may be of interest standalone and thus have separate test playbooks to test them.

### Docker

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_docker.yml --private-key=dev-server/key -u admin -i dev-server/inventory
```

### python-packages

The latest version of the **pip** tool and the **docker** package (version 3.2.1 by default) will be installed.

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_python_packages.yml --private-key=dev-server/key -u admin -i dev-server/inventory
```

## Ansible Playbooks

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

If you provisioned an aws cluster, type:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_cluster_ha.yml --private-key=dev-cluster/aws/key -u admin -i dev-cluster/aws/inventory
```

If you provisioned a scaleway cluster (assuming your set your local private key as trusted on your account), type:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_cluster_ha.yml --private-key=~/.ssh/id_rsa -u root -i dev-cluster/scaleway_arm64/inventory
```

If you provisioned a local libvirt cluster, type:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_cluster_ha.yml -i dev-cluster/local/inventory
```

Some customizations are possible by passing the following variables to the playbook:
- kubernetes_admin: Specifies a user that will be configured on the machines to run kubectl commands. Defaults to the user you run the playbooks with.
- api_url: Specifics an url (with some sort of load_balancing) that can be used to access the masters' API. Defaults to the load balancer's IP if a load balancer is present in the inventory.
- connection_timeout: Specifies the connection timeout if you are using a load-balancer. Defaults to 3000ms.
- client_timeout: Specifies the frontend response timeout if you are using a load-balancer. Defaults to 3000ms.
- server_timeout: Specifies the backend response timeout if you are using a load-balancer. Defaults to 3000ms.

Additionally, the following variable can be set on hosts in the inventory:
- internal_ip: Specifies an ip for the machine that should be used when connecting to other machines in the k8 cluster. Defaults to the inventory hostname of the machine.

#### Note About Load Balancer

The playbook will, optionally, provision a load balancer, although it does not (yet) provide a high availability solution for the load balancing.

If the load balancing part of the script is used, the ip of the first load balancer in the inventory will be used by the k8 cluster for load balancing (making any extra load balancers in the inventory pointless). This is fine for a mock/dev environment, but not suitable for production as it makes the load balancer a single point of failure.

A high availability solution may be obtained by leaving the **load_balancers** inventory empty and doing the following:
- If you are using a cloud provider that provides a load balancing service, setup a load balancer with your cloud provider and pass its url to the playbook via the **api_url** ansible variable
- Use a dynamic dns with failure detection like Consul (at that point, the load balancers become optional). If you opt for this, you can make the consul domain either point to a cluster of load balancers or directly to the masters. You can pass the consul domain to **api_url**.

While I could have provided a direct integration with an aws load balancer in the terraformed test environments, I opted to use a less scalable single haproxy setup even for the tests as I really want this playbook to be able to provide a working environment that is cloud agnostic (otherwise, I'd simply be using Kops and not be bothering with this project).

I will later investigate a consul integration within the playbook to achieve true high availability with no extra steps (at least for internal use within the k8 cluster, some extra steps will realistically be needed to access the master API from the outside).

#### Note About Stores

The playbook requires separate group entries in your inventory for **masters** and **stores**. If you don't want your masters machines to be separate from the etcd stores, you can simply define the same set in machines in both groups.

#### Note About Inventory Changes

Currently, only the following inventory changes are supported for an existing kubernetes cluster:

- Adding more workers
- Adding more masters (provided the first master in the list is a pre-existing master)

The above changes can be applied to a running cluster simply by modifying the inventory and running the playbook again.

### k8 Base Image

This playbook provisions the **Docker** and **Kubeadm** kubernetes dependencies to all the machines in the inventory.

The idea behind it is to execute this playbook on a single machine and then make a re-usable image out of that machine.

#### Usage 

Type:

```
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/k8_base_image.yml --private-key=<Your ssh key> -u <The vm's sudo user> -i <The vm's inventory>
```

## Docker Image

The ansible scripts are also available as a Docker image for greater convenience.

The image is: **magnitus/setup-scripts:latest**

The entrypoint of the image is a Python script that will launch an ansible playbook.

The script is composable with the following parameters:

- ANSIBLE_SSH_KEY: ssh key to use to connect to the target machines. The value is expected to be a file that is located in the **/opt/keys** directory of the container. Can be not defined or an empty string in which case no key is passed (which may be ok if for example you have an ssh password defined in the inventory). Defaults to not defined.
- ANSIBLE_USER: User that ansible will ssh as on the target machines. Defaults to **root**.
- ANSIBLE_INVENTORY: Inventory file to use to run the playbook on. The value is expected to be a file that is located in the **/opt/inventories** directory of the container. Defaults to **inventory**.
- ANSIBLE_PLAYBOOK: Playbook to run. The value is expected to be the base filename (without the **.yml** suffix) of the playbook. Defaults to **k8_cluster_ha**.

Example running the image against the aws test environment from the root directory of the project:

```
docker run --rm \
           -e "ANSIBLE_SSH_KEY=key" \
           -e "ANSIBLE_USER=admin" \
           -e "ANSIBLE_PLAYBOOK=k8_cluster_ha" \
           -e "ANSIBLE_INVENTORY=inventory" \
           -v $(pwd)/dev-cluster/aws/inventory:/opt/inventories/inventory \
           -v $(pwd)/dev-cluster/aws/key:/opt/keys/key \
           magnitus/setup-scripts:latest
```