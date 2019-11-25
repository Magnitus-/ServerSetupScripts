# Purpose

Image that wraps kubespray to remotely setup hosts.

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