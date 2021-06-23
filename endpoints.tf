##################################################
# File: endpoints.tf                             #
# Created Date: 03092019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Setup initial S3 End point        #
#                                                #
# Change History:                                #
# 03092019: Initial File                         #
#                                                #
##################################################

resource "aws_vpc_endpoint" "private-s3" {
   count           = var.enable-s3-endpoint == true ? 1 : 0
   vpc_id          = aws_vpc.main_vpc.id
   service_name    = "com.amazonaws.${var.region}.s3"
   route_table_ids = aws_route_table.privrt.*.id
}


resource "aws_vpc_endpoint" "private-dynamodb" {
   count           = var.enable-dynamodb-endpoint == true ? 1 : 0
   vpc_id          = aws_vpc.main_vpc.id
   service_name    = "com.amazonaws.${var.region}.dynamodb"
   route_table_ids = aws_route_table.privrt.*.id
}

resource "aws_vpc_endpoint" "private-interface-endpoints" {
  for_each                  = {for endpoint in var.private_endpoints : endpoint.name => endpoint}
  vpc_id                    = aws_vpc.main_vpc.id
  service_name              = replace(each.value.service, "<REGION>", var.region)
  private_dns_enabled       = lookup(each.value, "private_dns_enabled", true)
  vpc_endpoint_type         = "Interface"
  subnet_ids                = zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.id, local.num-availbility-zones))[each.value.subnet]
  security_group_ids        = compact(split("|", each.value.security_group))
  tags                      = merge(var.tags, map("Name", "${each.value.name}"))
}

resource "aws_vpc_endpoint" "GatewayEndPoint" {
  count  = var.deploy_gwep && !(var.egress_only_internet_gateway) ? 1 : 0
  vpc_id            = aws_vpc.main_vpc.id
  vpc_endpoint_type = "GatewayLoadBalancer"
  subnet_ids        = aws_subnet.gwep.0.id
  service_name      = var.gwep_service_name
}