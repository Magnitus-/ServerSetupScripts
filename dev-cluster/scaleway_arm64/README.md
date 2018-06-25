# Purpose

This is a terraform environment for a fleet of Scaleway arm64 machines.

You can spin up an arbitrary number of masters nodes and an arbitrary number of worker nodes. If you opt to spin up more than one master nodes, a load-balancer node will be spun up as well.

You'll need terraform to spin up the cluster.

# Manual Setup Steps

- For the ssh key of the machines, you will need to manually authenticate your ssh key on the Scaleway dashboard. If the key is not **~/.ssh/id_rsa** on your host, make sure to override the **ssh_key** variable with the path of the key you are using on your host when you call the terraform scripts.
- You will also need to define your Scaleway credentials (organization id and secret key) in environment variables prior to running Terraform as explained at the bottom of this page: https://www.terraform.io/docs/providers/scaleway/


# Setup Test Environment

Type the following to spin up the default of 3 master nodes, 1 worker node and a load balancer:

```
terraform apply
```

You can tear down the above environment when done by typing:

```
terraform destroy
```

Alternatively, you can spin up a custom number of master and worker nodes by overwriting the **workers_count** and **masters_count** variables prior to creating the environment. You can modify their value in the **variables.tf** file, but it maybe more straightforward to overwrite their value when calling **terraform apply**.

For example, the following call will spin up 3 masters, 3 workers and a load balancer:

```
terraform apply -var 'workers_count=3' -var 'masters_count=3'
```

Once you would be done with the above, you would tear down the machines by typing:

```
terraform destroy -var 'workers_count=3' -var 'masters_count=3'
```

# Artifacts

The terraform script will yield the following artifacts:

- An **inventory** file that you can use to run the ansible playbooks on

## Sshing Into Test environment

Type:

```
ssh -i <YourKey> root@<machineIP>
```

Here, **machineIP** is the ip of any of the machines in the **inventory** file

# Stability Note

Provisioning of the Scaleway machines with the Terraform script has not proven completely reliable so far.

First of all, it seems to only be able to provision one machine at a time.

Second, in about 50% of cases, it hangs at some point (could be that it was just incredibly slow beyond my patience to wait) trying to provision a server that remains "off" and never boots, forcing me to perform a terraform destroy and then cleanup the resources of the server that didn't start.

Even with those caveats, I still consider the Terraform route faster than provisioning the machines by hand.

# Time Optimization

You probably won't be spinning the environments repeatedly for testing purporses like I did, but regardless, if you want to speed up the provision of a cluster a little, you can do the following:

- Create a single arm64 debian machine on Scaleway
- Run the **k8_base_image** playbook on it
- Take a snapshot of the vm and make an image from it
- Destroy your vm
- Get the ID of your image from the Scaleway dashboard
- When you provision the terraform environment, pass the ID of your image to the **image** variable (ie, **terraform apply -var 'image=<ID>'**). Then, your vms will have **Docker** and **Kubeadm** pre-installed and the playbooks won't have to install them.