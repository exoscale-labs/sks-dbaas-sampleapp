locals {
  zone = "de-fra-1"
}

variable "username" {
  description = "The username for the DB master user"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "The password for the DB master user"
  type        = string
  sensitive   = true
}

# Create a MySQL database for WordPress
# https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/database
resource "exoscale_database" "wordpress" {
  zone = local.zone
  name = "wordpress"
  type = "mysql"
  plan = "hobbyist-1"
  maintenance_dow  = "sunday"
  maintenance_time = "23:00:00"
  termination_protection = false

  mysql {
    admin_username = var.username
    admin_password = var.password
  }
}

output "database_uri" {
  value = exoscale_database.wordpress.uri
}

# This resource will create the control plane
# https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_cluster
resource "exoscale_sks_cluster" "SKS-Cluster" {
  zone          = local.zone
  name          = "webcluster"
  version       = "1.21.7"
  description   = "Cluster for Wordpress"
  service_level = "pro"
  cni           = "calico"
}

# A security group so the nodes can communicate and we can pull logs
resource "exoscale_security_group" "sks_nodes" {
  name        = "sks_nodes"
  description = "Allows traffic between sks nodes and public pulling of logs"
}

resource "exoscale_security_group_rule" "sks_nodes_logs_rule" {
  security_group_id = exoscale_security_group.sks_nodes.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 10250
  end_port          = 10250
  user_security_group_id = exoscale_security_group.sks_nodes.id
}

resource "exoscale_security_group_rule" "sks_nodes_calico" {
  security_group_id      = exoscale_security_group.sks_nodes.id
  type                   = "INGRESS"
  protocol               = "UDP"
  start_port             = 4789
  end_port               = 4789
  user_security_group_id = exoscale_security_group.sks_nodes.id
}

resource "exoscale_security_group_rule" "sks_nodes_ccm" {
  security_group_id = exoscale_security_group.sks_nodes.id
  type              = "INGRESS"
  protocol          = "TCP"
  start_port        = 30000
  end_port          = 32767
  cidr              = "0.0.0.0/0"
}

# This provisions an instance pool of nodes which will run the kubernetes
# workloads. We can attach multiple nodepools to the cluster
# https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_nodepool
# Check instance types here
# https://www.exoscale.com/pricing/#/compute/
resource "exoscale_sks_nodepool" "workers" {
  zone               = local.zone
  cluster_id         = exoscale_sks_cluster.SKS-Cluster.id
  name               = "workers"
  instance_type      = "standard.medium"
  size               = 3
  security_group_ids = [exoscale_security_group.sks_nodes.id]
}
