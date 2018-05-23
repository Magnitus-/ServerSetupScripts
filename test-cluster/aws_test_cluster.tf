provider "aws" {
  region = "us-east-1"
}

resource "aws_default_vpc" "default" {}

resource "null_resource" "ssh_key" {
  provisioner "local-exec" {
    command = "ssh-keygen -t rsa -b 4096 -N '' -f $(pwd)/key"
  }

  provisioner "local-exec" {
    command = "rm key* || true"
    when    = "destroy"
  }
}

data "local_file" "ssh_public_key" {
  filename   = "${path.module}/key.pub"
  depends_on = ["null_resource.ssh_key"]
}

#https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch
data "aws_ami" "debian" {
  most_recent = true

  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2-2018-03-11-19642"]
  }

  owners = ["379101102735"]
}

resource "aws_key_pair" "test_cluster" {
  depends_on = ["null_resource.ssh_key"]
  key_name   = "test-cluster-key"
  public_key = "${data.local_file.ssh_public_key.content}"
}

resource "aws_security_group" "test_cluster_ssh" {
  name        = "test_cluster_ssh"
  description = "Allow inbound ssh traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "test_cluster_outbound" {
  name        = "test_cluster_outbound"
  description = "Allow all outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "test_cluster_internal" {
  name        = "test_cluster_internal"
  description = "Allow all internal traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
  }
}

resource "aws_instance" "test_workers" {
  ami             = "${data.aws_ami.debian.id}"
  instance_type   = "t2.small"
  key_name        = "test-cluster-key"
  security_groups = ["${aws_security_group.test_cluster_ssh.name}", "${aws_security_group.test_cluster_outbound.name}", "${aws_security_group.test_cluster_internal.name}"]
  count           = "${var.workers_count}"
}

resource "aws_instance" "test_masters" {
  ami             = "${data.aws_ami.debian.id}"
  instance_type   = "t2.small"
  key_name        = "test-cluster-key"
  security_groups = ["${aws_security_group.test_cluster_ssh.name}", "${aws_security_group.test_cluster_outbound.name}", "${aws_security_group.test_cluster_internal.name}"]
  count           = "${var.masters_count}"
}

resource "aws_instance" "test_load_balancers" {
  ami             = "${data.aws_ami.debian.id}"
  instance_type   = "t2.small"
  key_name        = "test-cluster-key"
  security_groups = ["${aws_security_group.test_cluster_ssh.name}", "${aws_security_group.test_cluster_outbound.name}", "${aws_security_group.test_cluster_internal.name}"]
  count           = "${var.masters_count > 1 ? 1 : 0}"
}

resource "null_resource" "inventory" {
  triggers {
    test_worker_id = "${join(",", aws_instance.test_workers.*.id)}"
    test_master_id = "${join(",", aws_instance.test_masters.*.id)}"
    test_consul_id = "${join(",", aws_instance.test_load_balancers.*.id)}"
  }

  provisioner "local-exec" {
    command = "echo '[masters]\n${join("\n", aws_instance.test_masters.*.public_ip)}\n' > inventory"
  }

  provisioner "local-exec" {
    command = "echo '[workers]\n${join("\n", aws_instance.test_workers.*.public_ip)}\n' >> inventory"
  }

  provisioner "local-exec" {
    command = "echo '[load_balancers]\n${join("\n", aws_instance.test_load_balancers.*.public_ip)}' >> inventory"
  }

  provisioner "local-exec" {
    command = "rm inventory || true"
    when    = "destroy"
  }
}
