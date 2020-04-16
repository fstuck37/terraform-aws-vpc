##################################################
# File: peerlink.tf                              #
# Created Date: 03222019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Setup VPC Peer Link               #
#                                                #
# Change History:                                #
# 03222019: Initial File                         #
#                                                #
##################################################

resource "aws_vpc_peering_connection" "peer" {
  for_each      = var.peer_requester
  vpc_id        = aws_vpc.main_vpc.id
  peer_vpc_id   = element(split("|", each.value),1)
  peer_owner_id = element(split("|", each.value),0)
  auto_accept   = var.acctnum == element(split("|", each.value),0) ? true : false

# /*
#   accepter {
#     allow_classic_link_to_remote_vpc = false
#     allow_remote_vpc_dns_resolution  = element(split("|", var.peer_requester[element(keys(var.peer_requester),count.index)]),3)
#     allow_vpc_to_remote_classic_link = false
#   }
# */

  requester {
    allow_classic_link_to_remote_vpc = false
    allow_remote_vpc_dns_resolution  = element(split("|", each.value),3)
    allow_vpc_to_remote_classic_link = false
  }

  tags = merge(var.tags, map("Name", "${each.key}-peerlink"))
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  for_each                  = var.peer_accepter
  vpc_peering_connection_id = element(split("|", each.value),0)
  auto_accept               = true
  tags                      = merge(var.tags, map("Name", "${each.key}-peerlink"))
}


resource "aws_route" "accepter_routes" {
  for_each                  = {for route in local.peerlink_accepter_routes : route.name => route}
  route_table_id            = each.value.route_table
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = each.value.conn_id
}

resource "aws_route" "requester_routes" {
  for_each                  = {for route in local.peerlink_requester_routes : route.name => route}
  route_table_id            = each.value.route_table
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer[each.value.peer_link_name].id
}
