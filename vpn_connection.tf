resource "aws_customer_gateway" "aws_customer_gateways" {
  for_each = var.vpc_connections
    bgp_asn = each.value.bgp_asn
    ip_address = each.value.peer_ip_address
    type = "ipsec.1"
    tags = merge(
      var.tags,
      map("Name",each.key)
    )
}

resource "aws_vpn_connection" "aws_vpn_connections" {
  for_each = var.vpc_connections
    Name                  = each.key
    customer_gateway_id   = aws_customer_gateway.aws_customer_gateways[each.key].id]
    static_routes_only    = each.value.static_routes_only
    tunnel1_inside_cidr   = each.value.tunnel1_inside_cidr
    tunnel1_preshared_key = each.value.tunnel1_preshared_key
    tunnel2_inside_cidr   = each.value.tunnel2_inside_cidr
    tunnel2_preshared_key = each.value.tunnel2_preshared_key

    tags = merge(
      var.tags,
      map("Name",each.key)
    )
}

resource "aws_vpn_connection_route" "aws_vpn_connection_routes" {
  count = length(local.vpn_connection_routes)
  vpn_connection_id = aws_vpn_connection.aws_vpn_connections[local.vpn_connection_routes.*.name[count.index]].id
  destination_cidr_block = local.vpn_connection_routes.*.cidr[count.index]
}