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

variable subnet {
  type = string
}

variable image_id {
  type = string
}


output "ips" {
  value = join("\n", openstack_compute_instance_v2.node.*.access_ip_v4)
}

output "name-ips" {
  value = join("\n", formatlist("%s %s",openstack_compute_instance_v2.node.*.access_ip_v4, openstack_compute_instance_v2.node.*.name))
}

resource "openstack_networking_port_v2" "network-port" {
  count          = var.compute_count
  name           = format("%s-port-%02d", var.base_name, count.index)
  network_id     = var.network
  admin_state_up = "true"

  fixed_ip {
    subnet_id = var.subnet
  }

  allowed_address_pairs {
    ip_address = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "node" {
  count           = var.compute_count
  name            = format("%s-%02d", var.base_name, count.index)
  image_id        = var.image_id
  flavor_name     = "ssc.medium"
  key_pair        = "viklund mac pro"
  security_groups = ["default"]

  network {
    port = openstack_networking_port_v2.network-port[count.index].id
  }
}
