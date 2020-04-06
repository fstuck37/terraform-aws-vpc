##################################################
# File: inetgw.tf                                #
# Created Date: 03202019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates an Internet Gateway       #
#                                                #
# Change History:                                #
# 03202019: Initial File                         #
#                                                #
##################################################

resource "aws_internet_gateway" "inet-gw" {
  count = contains(keys(var.subnets), "pub") ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    map("Name",format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${replace(var.region,"-", "")}-igw" )),
    local.resource-tags["aws_internet_gateway"]
  )
}