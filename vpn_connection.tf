resource "aws_customer_gateway" "aws_customer_gateways" {
  for_each = var.vpn_connections
    type = "ipsec.1"
    bgp_asn = merge(var.default_vpn_connections, each.value).bgp_asn
    ip_address = merge(var.default_vpn_connections, each.value).peer_ip_address
    tags = merge(
      var.tags,
      map("Name",each.key)
    )
}

resource "aws_vpn_connection" "aws_vpn_connections" {
  for_each = var.vpn_connections
    type = "ipsec.1"
    vpn_gateway_id        = aws_vpn_gateway.vgw.id
    customer_gateway_id   = aws_customer_gateway.aws_customer_gateways[each.key].id
    static_routes_only    = merge(var.default_vpn_connections, each.value).static_routes_only
    tunnel1_inside_cidr   = merge(var.default_vpn_connections, each.value).tunnel1_inside_cidr == "" ? null : merge(var.default_vpn_connections, each.value).tunnel1_inside_cidr
    tunnel1_preshared_key = merge(var.default_vpn_connections, each.value).tunnel1_preshared_key == "" ? null : merge(var.default_vpn_connections, each.value).tunnel1_preshared_key
    tunnel2_inside_cidr   = merge(var.default_vpn_connections, each.value).tunnel2_inside_cidr == "" ? null : merge(var.default_vpn_connections, each.value).tunnel2_inside_cidr
    tunnel2_preshared_key = merge(var.default_vpn_connections, each.value).tunnel2_preshared_key == "" ? null : merge(var.default_vpn_connections, each.value).tunnel2_preshared_key

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




