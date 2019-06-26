variable name {
  description = "Name of the network"
  type = "string"
}

variable cidr {
  description = "CIDR of the network"
  type = "string"
}

variable external_network_id {
  description = "External Network ID"
  type = "string"
}

output "network-id" {
  value = openstack_networking_network_v2.network.id
}

output "subnet-id" {
  value = openstack_networking_subnet_v2.network-subnet.id
}

resource "openstack_networking_network_v2" "network" {
  name = var.name
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "network-subnet" {
  name = format("%s-subnet", var.name)
  network_id = openstack_networking_network_v2.network.id
  cidr = var.cidr
  ip_version = 4
}
/*
resource "openstack_networking_router_v2" "network-router" {
  name = format("%s-router", var.name)
  external_network_id = var.external_network_id
  admin_state_up = true
}

resource "openstack_networking_router_interface_v2" "router-interface" {
  router_id = openstack_networking_router_v2.network-router.id
  subnet_id = openstack_networking_subnet_v2.network-subnet.id
}
*/
