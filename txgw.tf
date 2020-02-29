resource "aws_ec2_transit_gateway_vpc_attachment" "txgw_attachment" {
  count              = var.transit_gateway_id == false ? 0 : 1
  subnet_ids         = local.map_subnet_id_list[element(var.subnet-order,1)]
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main_vpc.id
}


resource "aws_route" "txgw-routes" {
  count                  = var.transit_gateway_id == false ? 0 : length(var.transit_gateway_routes) * local.num-availbility-zones
  
  route_table_id         = aws_route_table.privrt.*.id[module.txgw-route.e1-list[count.index]]
  destination_cidr_block = var.transit_gateway_routes[module.txgw-route.e2-list[count.index]]
  transit_gateway_id     = var.transit_gateway_id
}

module "txgw-route" {
  source  = "git::https://github.com/fstuck37/doubleiterator.git"
  e1-size = local.num-availbility-zones
  e2-size = length(var.transit_gateway_routes)
}
