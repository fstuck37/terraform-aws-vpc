variable "peer_requester" {
  description = "Optional : Map of Peer Link Name with a value of [Peer AWS Account Number]|[Peer VPC_ID]|[Peer VPC CIDR]|[allow_remote_vpc_dns_resolution]. This only creates the requester half of the connection. Since maps our lexically prepend the VPC name with a alpha character so they flow alphabetically, for example a-peerlink1, b-peerlink2, etc."  type = map(string)
  default = {
    A_DaaSv2      = "219829223284|vpc-833793e6|10.241.0.0/22|false"
    B_advmktgprod = "503482265532|vpc-65ffde02|10.244.192.0/19|false"
  }
}

variable "peer_accepter" {
  description = "Optional : Map of Peer Link Name with a value of [vpc_peering_connection_id]|[Peer VPC CIDR]. This only creates the accepter half of the connection. Since maps 
our lexically prepend the VPC name with a alpha character so they flow alphabetically, for example a-peerlink1, b-peerlink2, etc."
  type = map(string)
  default = {
    A_entinf_us-east-1_mgt = "pcx-2c9e0945|10.242.144.0/20"
    B_uss_mgt              = "pcx-c46fe2ad|10.241.8.0/24"
    C_poccerta-useast1-dev = "pcx-0db1d80ff5b9da16a|100.64.1.0/24"
    D_entinf_us-west-2_mgt = "pcx-0411295f41ecfbbb4|10.249.56.0/22"
    E_poc_us-west-2_dev    = "pcx-09e91f2a4d0b727fe|10.249.48.0/22"
  }
}

locals {
  peerlink_accepter_routes = flatten([
  for rt in aws_route_table.privrt : [
    for key, value in var.peer_accepter : {
      name        = "${rt.id}-${element(split("|", value),1)}" 
      route_table = rt.id
      conn_id     = element(split("|", value),1)
      cidr        = element(split("|", value),2)
      }
    ]
  ])

  peerlink_requester_routes = flatten([
  for rt in aws_route_table.privrt : [
    for key, value in var.peer_requester : {
      name            = "${rt.id}-${element(split("|", value),2)}"
      peer_link_name  = key
      route_table     = rt.id
      account         = element(split("|", value),1)
      vpc_id          = element(split("|", value),2)
      cidr            = element(split("|", value),3)
      dns_resolution  = element(split("|", value),4)
      }
    ]
  ])
}

output "insanity" {
  value = local.peerlink_requester_routes
}

output "insanity2" {
  value = local.peerlink_accepter_routes
}
