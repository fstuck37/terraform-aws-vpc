##################################################
# File: dxgw.tf                                  #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates ACL                       #
#                                                #
# Change History:                                #
# 03192019: Initial Test File                    #
#                                                #
##################################################

resource "aws_dx_gateway_association" "aws_dx_gateway_association" {
  count = var.dx_gateway_id == "false" ? 0 : 1
  dx_gateway_id = var.dx_gateway_id
  associated_gateway_id = aws_vpn_gateway.vgw.id
}
