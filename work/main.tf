#resource openstack_networking_floatingip_v2 floatip_1 {
#  pool = ""
#}


### VARS

variable "image-id" {
  type = string
  #default = "ba115875-5332-4f04-84bc-429d6730b3ab" ## Debian
  #default = "f8e54e0d-6337-449f-a8f3-c0a40339d827" ## Ubuntu
  #default = "3301175c-f322-4013-96c5-e2c3523083d5"
  default = "995da339-7698-49f0-91de-b20e49cb8fe2"
}

variable "external-network" {
  type = string
  default = "2c3fb52b-973d-434d-9284-c8f97a48ce0b"
  #default = "52b76a82-5f02-4a3e-9836-57536ef1cb63"
}

variable "floating-ip" {
  type = string
  default = "130.239.81.217"
}


### SECURITY GROUPS ###


### NETWORK ###

module "k8shard-net" {
  source = "./tf/network"
  name = "k8shard-net"
  cidr = "10.0.0.0/24"
  external_network_id = "52b76a82-5f02-4a3e-9836-57536ef1cb63"
}

resource "openstack_networking_port_v2" "network-port" {
  name = "a-network-port"
  network_id = module.k8shard-net.network-id
  admin_state_up = "true"

  fixed_ip {
    subnet_id = module.k8shard-net.subnet-id
  }

  allowed_address_pairs {
    ip_address = "0.0.0.0/0"
  }
}



### COMPUTES ###

resource "openstack_compute_instance_v2" "k8shard-master" {
  name = "master"
  image_id = var.image-id
  flavor_name = "ssc.medium"
  key_pair = "viklund mac pro"
  security_groups = ["default"]

  network {
    uuid = var.external-network
  }

  network {
    port = openstack_networking_port_v2.network-port.id
  }
}



resource "openstack_networking_subnet_v2" "controller-subnet" {
  name = format("k8shard-controller-subnet")
  network_id = module.k8shard-net.network-id
  cidr = "10.10.0.0/16"
  ip_version = 4
  dns_nameservers = ["8.8.8.8"]
}

module "controllers" {
  source = "./tf/compute"
  base_name = "controller"
  compute_count = 3
  network = module.k8shard-net.network-id
  subnet = openstack_networking_subnet_v2.controller-subnet.id
  image_id = var.image-id
}


resource "openstack_networking_subnet_v2" "worker-subnet" {
  name = "k8shard-worker-subnet"
  network_id = module.k8shard-net.network-id
  cidr = "10.20.0.0/16"
  ip_version = 4
  dns_nameservers = ["8.8.8.8"]
}

module "workers" {
  source = "./tf/compute"
  base_name = "worker"
  compute_count = 3
  network = module.k8shard-net.network-id
  subnet = openstack_networking_subnet_v2.worker-subnet.id
  image_id = var.image-id
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = var.floating-ip
  instance_id = openstack_compute_instance_v2.k8shard-master.id
}

data "template_file" "ansible_inventory" {
  template = file("${path.root}/inventory.tmpl")

  vars = {
    ip          = var.floating-ip
    internal_ip = openstack_compute_instance_v2.k8shard-master.network[1].fixed_ip_v4
    workers     = join("\n", formatlist("%-9s ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${var.floating-ip}' router=%s", split("\n",module.workers.ips),  openstack_compute_instance_v2.k8shard-master.network[1].fixed_ip_v4))
    controllers = join("\n", formatlist("%-9s ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${var.floating-ip}' router=%s", split("\n",module.controllers.ips), openstack_compute_instance_v2.k8shard-master.network[1].fixed_ip_v4))
  }
}

data "template_file" "hosts_file" {
  template = "$${content}"

  vars = {
    content = format("%s %s\n%s\n%s", 
      openstack_compute_instance_v2.k8shard-master.network[1].fixed_ip_v4, openstack_compute_instance_v2.k8shard-master.name,
      module.controllers.name-ips, module.workers.name-ips)
  }
}

resource "null_resource" "ansible_inventory_writer" {
  triggers = { uuid = uuid() }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.ansible_inventory.rendered}\" > \"${path.root}/inventory\""
  }
}

resource "null_resource" "hosts_file_writer" {
  triggers = { uuid = uuid() }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.hosts_file.rendered}\" > \"${path.root}/hosts\""
  }
}
