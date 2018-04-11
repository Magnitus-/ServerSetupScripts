# Purpose

Scripts to remotely setup hosts via ansible

As I'm mostly using Docker, the requirements are quite minimal.

## Setup Test environment

You need terraform for this. Note that the test environment is on AWS, so you should not be running it indefinitely.

Go in ```test-environment``` and type:

```
terraform apply
```

You'll also need to specify **yes**

To destroy it, you can simply type:

```
terraform destroy
```

## Sshing Into Test environment

Go in ```test-environment``` and look at the **inventory** file to get the test server ip.

From there, in the **test-environment** directory, type:

```
ssh -i key admin@<ip of the host>
```

## Test Ansible roles

### Docker

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_docker.yml --private-key=test-environment/key -u admin -i test-environment/inventory
```

### Python python-packages

The latest version of the **pip** tool and the **docker** package (version 3.2.1 by default) will be installed.

From the top-level directory, type:

```
ansible-playbook test-playbooks/install_python_packages.yml --private-key=test-environment/key -u admin -i test-environment/inventory
```
