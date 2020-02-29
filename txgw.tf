resource "aws_ec2_transit_gateway_vpc_attachment" "txgw_attachment" {
  count              = var.transit_gateway_id == false ? 0 : 1
  subnet_ids         = local.map_subnet_id_list[element(var.subnet-order,1)]
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.main_vpc.id
}