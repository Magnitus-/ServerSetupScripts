provider "scaleway" {
  region = "par1"
}

resource "scaleway_server" "masters" {
  name                = "master"
  image               = "${var.image}"
  type                = "ARM64-2GB"
  dynamic_ip_required = true

  count = "${var.masters_count}"
}

resource "scaleway_server" "workers" {
  name                = "worker"
  image               = "${var.image}"
  type                = "ARM64-2GB"
  dynamic_ip_required = true

  count = "${var.workers_count}"
}

resource "scaleway_server" "load_balancers" {
  name                = "load_balancer"
  image               = "${var.image}"
  type                = "ARM64-2GB"
  dynamic_ip_required = true

  count = "${var.masters_count > 1 ? 1 : 0}"
}

resource "null_resource" "inventory" {
  triggers {
    test_worker_id = "${join(",", scaleway_server.workers.*.id)}"
    test_master_id = "${join(",", scaleway_server.masters.*.id)}"
    test_consul_id = "${join(",", scaleway_server.load_balancers.*.id)}"
  }

  provisioner "local-exec" {
    command = "echo '[masters]\n${join("\n", formatlist("%s", scaleway_server.masters.*.public_ip))}\n' > inventory"
  }

  provisioner "local-exec" {
    command = "echo '[workers]\n${join("\n", formatlist("%s", scaleway_server.workers.*.public_ip))}\n' >> inventory"
  }

  provisioner "local-exec" {
    command = "echo '[load_balancers]\n${join("\n", formatlist("%s", scaleway_server.load_balancers.*.public_ip))}' >> inventory"
  }

  provisioner "local-exec" {
    command = "rm inventory || true"
    when    = "destroy"
  }
}
