output "vpc_id" {
  description = "The ID of the VPC"
  value = "${aws_vpc.main_vpc.id}"
}

output "vpc_name" {
  description = "The name of the VPC"
  value = "${format("%s", var.vpc-name == "true" ? "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" : var.vpc-name)}"
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


