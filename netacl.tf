##################################################
# File: pub-acl.tf                               #
# Created Date: 03192019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Creates ACL                       #
#                                                #
# Change History:                                #
# 03192019: Initial Test File                    #
#                                                #
##################################################

resource "aws_network_acl" "net_acl" {
  count = "${contains(keys(var.subnets), "pub") ? 1 : 0}"
  vpc_id = "${aws_vpc.main_vpc.id}"
  subnet_ids = "${local.pub-subnet-ids}"
  tags = "${merge(var.tags,map("Name",format("%s","${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-nacl")))}"
}

/* bypass_ingress_rules */
resource "aws_network_acl_rule" "acle-ingress-bypass" {
  count = "${contains(keys(var.subnets), "pub") ? length(var.bypass_ingress_rules) : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "${(count.index+1)*5}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${ element(split("|", var.bypass_ingress_rules[count.index]),0) }"
  from_port      = "${length(split("-",element(split("|", var.bypass_ingress_rules[count.index]),1))) < 2 ? element(split("|", var.bypass_ingress_rules[count.index]),1) : element(split("-",element(split("|", var.bypass_ingress_rules[count.index]),1)), 0)}"
  to_port        = "${length(split("-",element(split("|", var.bypass_ingress_rules[count.index]),1))) < 2 ? element(split("|", var.bypass_ingress_rules[count.index]),1) : element(split("-",element(split("|", var.bypass_ingress_rules[count.index]),1)), 1)}"
}

/* bypass_egress_rules */
resource "aws_network_acl_rule" "acle-egress-bypass" {
  count = "${contains(keys(var.subnets), "pub") ? length(var.bypass_egress_rules) : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "${(count.index+1)*5}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "${ element(split("|", var.bypass_egress_rules[count.index]),0) }"
  from_port      = "${length(split("-",element(split("|", var.bypass_egress_rules[count.index]),1))) < 2 ? element(split("|", var.bypass_egress_rules[count.index]),1) : element(split("-",element(split("|", var.bypass_egress_rules[count.index]),1)), 0)}"
  to_port        = "${length(split("-",element(split("|", var.bypass_egress_rules[count.index]),1))) < 2 ? element(split("|", var.bypass_egress_rules[count.index]),1) : element(split("-",element(split("|", var.bypass_egress_rules[count.index]),1)), 1)}"
}

/* block_ports ingress */
resource "aws_network_acl_rule" "acle-out-ports" {
  count = "${contains(keys(var.subnets), "pub") ? length(var.block_ports) : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "${(count.index*5)+1000}"
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${length(split("-",var.block_ports[count.index])) < 2 ? var.block_ports[count.index] : element(split("-",var.block_ports[count.index]), 0)}"
  to_port        = "${length(split("-",var.block_ports[count.index])) < 2 ? var.block_ports[count.index] : element(split("-",var.block_ports[count.index]), 1)}"
}

/* block_ports egress */
resource "aws_network_acl_rule" "acle-in-ports" {
  count = "${contains(keys(var.subnets), "pub") ? length(var.block_ports) : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "${(count.index*5)+1000}"
  egress         = true
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = "${length(split("-",var.block_ports[count.index])) < 2 ? var.block_ports[count.index] : element(split("-",var.block_ports[count.index]), 0)}"
  to_port        = "${length(split("-",var.block_ports[count.index])) < 2 ? var.block_ports[count.index] : element(split("-",var.block_ports[count.index]), 1)}"
}

/* block_ports ingress */
resource "aws_network_acl_rule" "acle-ingress" {
  count = "${contains(keys(var.subnets), "pub") ? length(var.ingress_block) : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "${(count.index*5)+5000}"
  egress         = false
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "${ var.ingress_block[count.index] }"
  from_port      = 0
  to_port        = 0
}

/* egress_block */
resource "aws_network_acl_rule" "acle-egress" {
  count = "${contains(keys(var.subnets), "pub") ? length(var.egress_block) : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "${(count.index*5)+5000}"
  egress         = true
  protocol       = "-1"
  rule_action    = "deny"
  cidr_block     = "${ var.egress_block[count.index] }"
  from_port      = 0
  to_port        = 0
}

/* allow everything else ingress  */
resource "aws_network_acl_rule" "acle-permit-ingress" {
  count = "${contains(keys(var.subnets), "pub") ? 1 : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "32000"
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

/* allow everything else egress */
resource "aws_network_acl_rule" "acle-permit-egress" {
  count = "${contains(keys(var.subnets), "pub") ? 1 : 0}"
  network_acl_id = "${join("",aws_network_acl.net_acl.*.id)}"
  rule_number    = "32000"
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
