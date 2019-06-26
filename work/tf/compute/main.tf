variable base_name {
  type = string
}

variable compute_count {
  type = number
  default = 1
}

variable network {
  type = string
}

variable image_id {
  type = string
}


output "ips" {
  value = join("\n", openstack_compute_instance_v2.node.*.access_ip_v4)
}


resource "openstack_compute_instance_v2" "node" {
  count           = var.compute_count
  name            = format("%s_%03d", var.base_name, count.index)
  image_id        = var.image_id
  flavor_name     = "ssc.medium"
  key_pair        = "viklund mac pro"
  security_groups = ["default"]

  network {
    uuid = var.network
  }
}
