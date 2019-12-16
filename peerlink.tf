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
  count         = length(var.peer_requester)
  vpc_id        = aws_vpc.main_vpc.id
  peer_vpc_id   = element(split("|", var.peer_requester[element(keys(var.peer_requester),count.index)]),1)
  peer_owner_id = element(split("|", var.peer_requester[element(keys(var.peer_requester),count.index)]),0)
  auto_accept   = var.acctnum == element(split("|", var.peer_requester[element(keys(var.peer_requester),count.index)]),0) ? true : false

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = merge(var.tags, map("Name", format("%s", "${element(keys(var.peer_requester),count.index)}-peerlink")))
}

resource "aws_route" "requester_routes" {
  count                     = (local.peerlink-size * local.routetable-size) > 0 ? local.peerlink-size * local.routetable-size : 0
  route_table_id            = aws_route_table.privrt.*.id[local.routetable-list[count.index]]
  destination_cidr_block    = element(split("|", var.peer_requester[element(keys(var.peer_requester),local.peerlink-list[count.index])]),2)
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.*.id[local.peerlink-list[count.index]]
}


resource "aws_vpc_peering_connection_accepter" "peer" {
  count                     = length(var.peer_accepter)
  vpc_peering_connection_id = element(split("|", var.peer_accepter[element(keys(var.peer_accepter),count.index)]),0)
  auto_accept               = true
  tags                      = merge(var.tags, map("Name", format("%s", "${element(keys(var.peer_accepter),count.index)}-peerlink")))
}

resource "aws_route" "accepter_routes" {
  count                     = (local.peerlink-accepter-size * local.routetable-size) > 0 ? local.peerlink-accepter-size * local.routetable-size : 0
  route_table_id            = aws_route_table.privrt.*.id[local.routetable-accepter-list[count.index]]
  destination_cidr_block    = element(split("|", var.peer_accepter[element(keys(var.peer_accepter),local.peerlink-accepter-list[count.index])]),1)
  vpc_peering_connection_id = element(split("|", var.peer_accepter[element(keys(var.peer_accepter),local.peerlink-accepter-list[count.index])]),0)
}
