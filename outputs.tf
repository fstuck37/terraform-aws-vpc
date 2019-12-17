output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main_vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value = "${format("%s", var.vpc-name == true ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)}"
}

output "subnet_ids" {
  description = "Map with keys based on the subnet names and values of subnet IDs"
  value = zipmap(data.template_file.subnet-name.*.rendered, aws_subnet.subnets.*.id)
}


output "map_subnet_id_list" {
  description = "Map with keys the same as subnet-order and values a list of subnet IDs"
  value = zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.id, local.num-availbility-zones))
}

output "pubrt_id" {
  description = "The ID of the public routing table"
  value = (join("",aws_route_table.pubrt.*.id))
}

output "privrt_id" {
  description = "List of IDs of the private routing tables"
  value = [aws_route_table.privrt.*.id]
}

output "vgw_id" {
  description = "The ID of the VPN Gateway."
  value = aws_vpn_gateway.vgw.id
}

output "peerlink_ids" {
  description = "Map with keys the same as the peer_requester variable and a value of the ID of the VPC Peering Connection."
  value = zipmap(keys(var.peer_requester), aws_vpc_peering_connection.peer.*.id)
}


output "subnet-order" {
  value = local.subnet-order
}