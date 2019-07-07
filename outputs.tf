output "vpc_id" {
  value = "${aws_vpc.main_vpc.id}"
}

output "vpc_name" {
  value = "${aws_vpc.main_vpc.id}"
}

output "subnet_ids" {
  value = "${zipmap(data.template_file.subnet-name.*.rendered, aws_subnet.subnets.*.id)}"
}


output "map_subnet_id_list" {
  value = "${ zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.id, local.num-availbility-zones) )}"
}

output "pubrt_id" {
  value = "${(join("",aws_route_table.pubrt.*.id))}" 
}

output "privrt_id" {
  value =  ["${aws_route_table.privrt.*.id}"]
}

output "vgw_id" {
  value = "${aws_vpn_gateway.vgw.id}"
}

output "peerlink_ids" {
  value = "${zipmap(keys(var.peer_requester), aws_vpc_peering_connection.peer.*.id) }"
}


