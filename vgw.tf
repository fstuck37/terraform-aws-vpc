##################################################
# File: vgw.tf                                   #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Setup VGW Gateway                 #
#                                                #
# Change History:                                #
# 03192019: Initial File                         #
#                                                #
##################################################

resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = merge(var.tags,map("Name",format("%s","${var.name-vars["account"]}-${var.name-vars["name"]}-vgw")))
}