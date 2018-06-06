# Overview

This is a single server environment on aws, useful for testing roles on a single machine.

You'll need terraform to spin it up.

# Setup

Go in this directory and type:

```
terraform apply
```

You'll also need to specify **yes**

To destroy it, you can simply type:

```
terraform destroy
```

# Artifacts

The terraform script will yield the following artifacts:

- A **key** file that you can use to ssh into the server
- An **inventory** file that you can use to run the test ansible playbooks on

# SSh

Type:

```
ssh -i key admin@<machineIP>
```

Here, **machineIP** is the ip of the machine which can be obtained from the **inventory** file