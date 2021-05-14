##################################################
# File: inetgw.tf                                #
# Created Date: 03202019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates an Internet Gateway       #
#                                                #
# Change History:                                #
# 03202019: Initial File                         #
# 05142021: Added egress only IGW                #
#                                                #
##################################################

resource "aws_internet_gateway" "inet-gw" {
  count = contains(keys(var.subnets), "pub") && !var.egress_only_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.tags,
    map("Name",format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${replace(var.region,"-", "")}-igw" )),
    local.resource-tags["aws_internet_gateway"]
  )
}

resource "aws_egress_only_internet_gateway" "eg-inet-gw" {
  count = contains(keys(var.subnets), "pub") && var.egress_only_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(
    var.tags,
    map("Name",format("%s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${replace(var.region,"-", "")}-igw" )),
    local.resource-tags["aws_internet_gateway"]
  )
}