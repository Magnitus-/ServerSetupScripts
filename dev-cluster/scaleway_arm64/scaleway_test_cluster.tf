provider "scaleway" {
  region = "par1"
}

resource "scaleway_server" "masters" {
  name                = "master"
  image               = "${var.image}"
  type                = "ARM64-2GB"
  dynamic_ip_required = true

  count = "${var.masters_count}"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.ssh_key)}"
    }

    inline = [
      "hostname master${count.index}",
    ]
  }
}

resource "scaleway_server" "workers" {
  name                = "worker"
  image               = "${var.image}"
  type                = "ARM64-2GB"
  dynamic_ip_required = true

  count = "${var.workers_count}"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.ssh_key)}"
    }

    inline = [
      "hostname worker${count.index}",
    ]
  }
}

resource "scaleway_server" "load_balancers" {
  name                = "load_balancer"
  image               = "${var.image}"
  type                = "ARM64-2GB"
  dynamic_ip_required = true

  count = "${var.masters_count > 1 ? 1 : 0}"

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.ssh_key)}"
    }

    inline = [
      "hostname lb${count.index}",
    ]
  }
}

resource "null_resource" "inventory" {
  triggers {
    test_worker_id = "${join(",", scaleway_server.workers.*.id)}"
    test_master_id = "${join(",", scaleway_server.masters.*.id)}"
    test_consul_id = "${join(",", scaleway_server.load_balancers.*.id)}"
  }

  provisioner "local-exec" {
    command = "echo '[masters]\n${join("\n", formatlist("%s internal_ip=%s", scaleway_server.masters.*.public_ip, scaleway_server.masters.*.private_ip))}\n' > inventory"
  }

  provisioner "local-exec" {
    command = "echo '[workers]\n${join("\n", formatlist("%s internal_ip=%s", scaleway_server.workers.*.public_ip, scaleway_server.workers.*.private_ip))}\n' >> inventory"
  }

  provisioner "local-exec" {
    command = "echo '[load_balancers]\n${join("\n", formatlist("%s internal_ip=%s", scaleway_server.load_balancers.*.public_ip, scaleway_server.load_balancers.*.private_ip))}' >> inventory"
  }

  provisioner "local-exec" {
    command = "rm inventory || true"
    when    = "destroy"
  }
}
