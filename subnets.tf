##################################################
# File: subnets.tf                               #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates subnets                   #
#                                                #
# Change History:                                #
# 03192019: Initial File                         #
#                                                #
##################################################

resource "aws_subnet" "subnets" {
  count             = length(var.subnets)*local.num-availbility-zones
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = contains(keys(var.fixed-subnets), element(local.subnet-order,local.subnets-list[count.index])) ? var.fixed-subnets[element(local.subnet-order,local.subnets-list[count.index])][local.azs-list[count.index]] : cidrsubnet(var.subnets[element(local.subnet-order,local.subnets-list[count.index])],ceil(log(length(var.zones[var.region]),2)),local.azs-list[count.index])
  availability_zone = element(var.zones[var.region],local.azs-list[count.index])
  tags              = merge(
    var.tags, 
    map("Name", contains(keys(var.fixed-name), element(local.subnet-order,local.subnets-list[count.index])) ? var.fixed-name[element(local.subnet-order,local.subnets-list[count.index])][local.azs-list[count.index]] : format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${element(local.subnet-order,local.subnets-list[count.index])}-az-${element(split("-", element(var.zones[var.region],local.azs-list[count.index])), length(split("-", element(var.zones[var.region],local.azs-list[count.index]))) - 1)}")),
    local.subnet-tags["${element(local.subnet-order,local.subnets-list[count.index])}"],
    local.resource-tags["aws_subnet"]
  )
}

data "template_file" "subnets-tags" {
  count    = length(var.subnets)*local.num-availbility-zones
  template = "${format("%02s", "${var.name-vars["account"]}-${var.name-vars["name"]}-${element(local.subnet-order,local.subnets-list[count.index])}-az-${element(split("-", element(var.zones[var.region],local.azs-list[count.index])), length(split("-", element(var.zones[var.region],local.azs-list[count.index]))) - 1)}")}"
}






