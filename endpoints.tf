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
   count           = var.enable-s3-endpoint == "true" ? 1 : 0
   vpc_id          = aws_vpc.main_vpc.id
   service_name    = "com.amazonaws.${var.region}.s3"
   route_table_ids = aws_route_table.privrt.*.id
}


resource "aws_vpc_endpoint" "private-dynamodb" {
   count           = var.enable-dynamodb-endpoint == "true" ? 1 : 0
   vpc_id          = aws_vpc.main_vpc.id
   service_name    = "com.amazonaws.${var.region}.dynamodb"
   route_table_ids = aws_route_table.privrt.*.id
}

resource "aws_vpc_endpoint" "private-interface-endpoints" {
   count              = length(var.private_endpoints)
   vpc_id             = aws_vpc.main_vpc.id
   service_name       = replace(var.private_endpoints[count.index], "<REGION>", var.region)
   vpc_endpoint_type  = "Interface"
   subnet_ids         = zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.id, local.num-availbility-zones))[var.private_endpoints_subnet]
   security_group_ids = compact(split("|", var.private_endpoints_security_group[count.index]))
}



