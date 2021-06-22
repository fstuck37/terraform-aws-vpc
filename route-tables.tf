##################################################
# File: route-tables.tf                          #
# Created Date: 03202019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Setup initial routing tables and  #
#              assigns them to the appropriate   #
#              subnets.                          #
#                                                #
# Change History:                                #
# 03202019: Initial File                         #
# 05142021: Added egress only IGW                #
#                                                #
##################################################

resource "aws_route_table" "pubrt" {
  count  = !contains(keys(var.subnets), "pub") ? 0 : 1
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-pub")),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_vpn_gateway_route_propagation" "pubrt" {
  count          = contains(keys(var.subnets), "pub") && var.enable_pub_route_propagation == true ? 1 : 0
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = aws_route_table.pubrt.*.id[0]
}

resource "aws_route_table" "privrt" {
  count            = length(var.zones[var.region])
  vpc_id           = aws_vpc.main_vpc.id
  propagating_vgws = [aws_vpn_gateway.vgw.id]
  tags             = merge(
    var.tags,
    map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-prod-az-${element(split("-", element(var.zones[var.region],count.index)), length(split("-", element(var.zones[var.region],count.index))) - 1)}")),
    local.resource-tags["aws_route_table"]
  )
  depends_on       = [aws_vpn_gateway.vgw]
}

resource "aws_route_table_association" "associations" {
  count          = length(var.subnets)*local.num-availbility-zones
  subnet_id      = aws_subnet.subnets.*.id[count.index]
  route_table_id = replace(data.template_file.subnets-tags.*.rendered[count.index], "pub", "") != data.template_file.subnets-tags.*.rendered[count.index] ? join("",aws_route_table.pubrt.*.id) : aws_route_table.privrt.*.id[count.index % length(var.zones[var.region])]
}

resource "aws_route" "privrt-gateway" {
  count                  = !contains(keys(var.subnets), "pub")  || !var.deploy_natgateways || var.dx_bgp_default_route ? 0 : local.num-availbility-zones
  route_table_id         = aws_route_table.privrt.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.*.id[count.index]
}

resource "aws_route" "pub-default" {
  count                  = contains(keys(var.subnets), "pub") && !var.egress_only_internet_gateway ? 1 : 0
  route_table_id         = join("",aws_route_table.pubrt.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet-gw.0.id
}

resource "aws_route" "pub-default-eg" {
  count                  = contains(keys(var.subnets), "pub") && var.egress_only_internet_gateway ? 1 : 0
  route_table_id         = join("",aws_route_table.pubrt.*.id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_egress_only_internet_gateway.eg-inet-gw.0.id
}


/* Gateway Endpoint Routing Setup */

resource "aws_route_table" "gweprt" {
  count  = var.deploy_gwep && !(egress_only_internet_gateway) ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-pub")),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_route" "gweprt-route" {
  count                  = var.deploy_gwep && !(egress_only_internet_gateway) ? 1 : 0
  route_table_id         = aws_route_table.gweprt.0.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet-gw.0.id
}

resource "aws_route_table_association" "gweprt" {
  count          = var.deploy_gwep && !(egress_only_internet_gateway) ? local.num-availbility-zones : 0
  subnet_id      = aws_subnet.gwep.*.id[count.index]
  route_table_id = aws_route_table.gweprt.id
}

resource "aws_route_table" "igwrt" {
  count  = var.deploy_gwep && !(egress_only_internet_gateway) ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(
    var.tags,
    map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-pub")),
    local.resource-tags["aws_route_table"]
  )
}

resource "aws_route_table_association" "igwrt-association" {
  count          = var.deploy_gwep && !(egress_only_internet_gateway) ? 1 : 0
  gateway_id     = aws_internet_gateway.inet-gw.id
  route_table_id = aws_route_table.igwrt.0.id
}

resource "aws_route" "igwrt-pub-route" {
  count  = var.deploy_gwep && !(egress_only_internet_gateway) ? 1 : 0
  route_table_id = aws_route_table.igwrt.0.id
  vpc_endpoint_id = aws_vpc_endpoint.GatewayLoadBalancer.0.id
  destination_cidr_block = var.subnets["pub"]
}


