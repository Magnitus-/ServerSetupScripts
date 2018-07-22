# Overview

This is a multi-machine cluster environment on aws, useful for testing the kubernetes playbooks.

You can spin up an arbitrary number of masters nodes and an arbitrary number of worker nodes. If you opt to spin up more than one master nodes, a load-balancer node will be spun up as well.

You'll need terraform to spin up the cluster.

# Setup Test Environment

Type the following to spin up the default of 1 master node, 3 worker nodes and no load balancer:

```
terraform apply
```

You can tear down the above environment when done by typing:

```
terraform destroy
```

Alternatively, you can spin up a custom number of master and worker nodes by overwriting the **workers_count** and **masters_count** variables prior to creating the environment. If you want the etcd stores to be on separate machines from the masters, you can also set **stores_count** to a non-zero value. You can modify their value in the **variables.tf** file, but it maybe more straightforward to overwrite their value when calling **terraform apply**.

For example, the following call will spin up 3 masters, 3 workers, 3 standalone stores and a load balancer:

```
terraform apply -var 'workers_count=3' -var 'masters_count=3' -var 'stores_count=3'
```

Once you would be done with the above, you would tear down the machines by typing:

```
terraform destroy -var 'workers_count=3' -var 'masters_count=3' -var 'stores_count=3'
```

# Artifacts

The terraform script will yield the following artifacts:

- A **key** file that you can use to ssh into any of the servers
- An **inventory** file that you can use to run the ansible playbooks on

## Sshing Into Test environment

Type:

```
ssh -i key admin@<machineIP>
```

Here, **machineIP** is the ip of any of the machines in the **inventory** file