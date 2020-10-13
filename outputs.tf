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
  value = length(data.template_file.subnet-name.*.rendered) == length(aws_subnet.subnets.*.id) ? zipmap(data.template_file.subnet-name.*.rendered, aws_subnet.subnets.*.id) : {}
}

output "map_subnet_id_list" {
  description = "Map with keys the same as subnet-order and values a list of subnet IDs"
  value = local.map_subnet_id_list
}

output "pubrt_id" {
  description = "The ID of the public routing table"
  value = (join("",aws_route_table.pubrt.*.id))
}

output "privrt_id" {
  description = "List of IDs of the private routing tables"
  value = aws_route_table.privrt.*.id
}

output "vgw_id" {
  description = "The ID of the VPN Gateway."
  value = aws_vpn_gateway.vgw.id
}

# output "peerlink_ids" {
#   description = "Map with keys the same as the peer_requester variable and a value of the ID of the VPC Peering Connection."
#   value = length(keys(var.peer_requester)) == length(aws_vpc_peering_connection.peer.*.id) ? zipmap(keys(var.peer_requester), aws_vpc_peering_connection.peer.*.id) : {}
# }

output "peerlink_ids" {
  value = merge(
    zipmap(
      [for v in aws_vpc_peering_connection_accepter.peer : v.tags.Name],
      [for v in aws_vpc_peering_connection_accepter.peer : v.id]),
    zipmap(
      [for v in aws_vpc_peering_connection.peer : v.tags.Name],
      [for v in aws_vpc_peering_connection.peer : v.id]
    ))
}
output "route_53_rules" {
  value = flatten(data.aws_route53_resolver_rules.shared_resolver_rule)
}

output "aws_ec2_transit_gateway_vpc_attachment" {
  description = "ID of the transit gateway attachment"
  value = (join("",aws_ec2_transit_gateway_vpc_attachment.txgw_attachment.*.id))
}

output "vpn_connections" {
  value = zipmap(
    [for v in aws_vpn_connection.aws_vpn_connections : v.tags.Name],	#Key
    [for v in aws_vpn_connection.aws_vpn_connections :  
      map(                                                              #Value
        "id", v.id,
        "tunnel1_address", v.tunnel1_address,
        "tunnel1_cgw_inside_address", v.tunnel1_cgw_inside_address,
        "tunnel1_vgw_inside_address", v.tunnel1_vgw_inside_address,
        "tunnel1_preshared_key", v.tunnel1_preshared_key,
        "tunnel1_bgp_asn", v.tunnel1_bgp_asn ,
        "tunnel1_bgp_holdtime", v.tunnel1_bgp_holdtime,
        "tunnel2_address", v.tunnel2_address,
        "tunnel2_cgw_inside_address", v.tunnel2_cgw_inside_address,
        "tunnel2_vgw_inside_address", v.tunnel2_vgw_inside_address,
        "tunnel2_preshared_key", v.tunnel2_preshared_key,
        "tunnel2_bgp_asn", v.tunnel2_bgp_asn ,
        "tunnel2_bgp_holdtime", v.tunnel2_bgp_holdtime
      )
    ]
  )
}