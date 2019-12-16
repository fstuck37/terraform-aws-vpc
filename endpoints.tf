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
   count = var.enable-s3-endpoint == "true" ? 1 : 0
   vpc_id = aws_vpc.main_vpc.id
   service_name = "com.amazonaws.${var.region}.s3"
   route_table_ids = aws_route_table.privrt.*.id
}
