provider "aws" {
  region     = "us-east-1"
}

resource "null_resource" "ssh_key" {
  provisioner "local-exec" {
    command = "ssh-keygen -t rsa -b 4096 -N '' -f $(pwd)/key"
  }

  provisioner "local-exec" {
    command = "rm key* || true"
    when = "destroy"
  }
}

data "local_file" "ssh_public_key" {
  filename = "${path.module}/key.pub"
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

resource "aws_key_pair" "test_server" {
  depends_on = ["null_resource.ssh_key"]
  key_name   = "test-server-key"
  public_key = "${data.local_file.ssh_public_key.content}"
}

resource "aws_security_group" "test_server" {
  name = "test_server"
  description = "Allow all outbound traffic. Allow ssh only for inbound"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "test_server" {
  ami           = "${data.aws_ami.debian.id}"
  instance_type = "t2.small"
  key_name = "test-server-key"
  security_groups = ["${aws_security_group.test_server.name}"]
}

resource "null_resource" "inventory" {
  triggers {
    test_server_id = "${join(",", aws_instance.test_server.*.id)}"
  }

  provisioner "local-exec" {
    command = "echo '[test_server]\n${aws_instance.test_server.public_ip}' > inventory"
  }

  provisioner "local-exec" {
    command = "rm inventory || true"
    when = "destroy"
  }
}
