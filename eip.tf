##################################################
# File: eip.tf                                   #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates an Elastic IP             #
#                                                #
# Change History:                                #
# 03192019: Initial File                         #
#                                                #
##################################################

resource "aws_eip" "eip" {
  count = contains(keys(var.subnets), "pub")  && !(var.deploy_natgateways == "false") ? local.num-availbility-zones : 0
  vpc = true
}






