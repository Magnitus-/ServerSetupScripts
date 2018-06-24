variable "workers_count" {
  default = 1
}

variable "masters_count" {
  default = 3
}

variable "image" {
  default = "c567a8be-a868-40b9-aba9-29c5f31fa11c"
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}
