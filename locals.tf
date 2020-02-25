locals {
  num-availbility-zones = "${length(var.zones[var.region])}"
  subnet-order = "${ coalescelist( var.subnet-order, keys(var.subnets)) }"

  /* NOTE: Requires that pub is first */
  pub-subnet-ids = ( length(aws_subnet.subnets.*.id) < local.num-availbility-zones ? [] : slice(aws_subnet.subnets.*.id, 0, local.num-availbility-zones )




  baselist = ["A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A",]
  azs-size = local.num-availbility-zones
  subnets-size = length(var.subnets)
  azs-list = split(",", join(",", data.template_file.azs-two.*.rendered))
  subnets-list = (split(",", join(",", data.template_file.subnets-two.*.rendered)))
  
  peerlink-size = length(var.peer_requester)
  routetable-size = length(var.zones[var.region])
  peerlink-list = split(",", join(",", data.template_file.peerlink-two.*.rendered))
  routetable-list = (split(",", join(",", data.template_file.routetable-two.*.rendered)))
  
  peerlink-accepter-size = length(var.peer_accepter)
  peerlink-accepter-list = split(",", join(",", data.template_file.peerlink-accepter-two.*.rendered))
  routetable-accepter-list = (split(",", join(",", data.template_file.routetable-accepter-two.*.rendered)))
}

data "template_file" "subnet-name" {
  count    = length(var.subnets)*local.num-availbility-zones
  template = lookup(aws_subnet.subnets.*.tags[count.index],"Name")
}

data "template_file" "azs-one" {
  count    = local.azs-size
  template = count.index
}
 
data "template_file" "azs-two" {
  count    = local.subnets-size
  template = join(",", data.template_file.azs-one.*.rendered)
}

data "template_file" "subnets-one" {
  count    = local.subnets-size
  template = count.index
}

data "template_file" "subnets-two" {
  count    = length(data.template_file.subnets-one.*.rendered)
  template = join(",",slice(split(",", replace(join(",", local.baselist), "A", data.template_file.subnets-one.*.rendered[count.index])), 0, local.azs-size))
}

/* Peer Link */
data "template_file" "routetable-one" {
  count    = local.routetable-size
  template = count.index
}

data "template_file" "routetable-two" {
  count    = local.peerlink-size
  template = join(",", data.template_file.routetable-one.*.rendered)
}

data "template_file" "peerlink-one" {
  count    = local.peerlink-size
  template = count.index
}

data "template_file" "peerlink-two" {
  count    = length(data.template_file.peerlink-one.*.rendered)
  template = join(",",slice(split(",", replace(join(",", local.baselist), "A", data.template_file.peerlink-one.*.rendered[count.index])), 0, local.routetable-size))
}


/* Peer Link Accepter */
data "template_file" "peerlink-accepter-one" {
  count    = local.peerlink-accepter-size
  template = count.index
}
 
data "template_file" "peerlink-accepter-two" {
  count    = local.routetable-size
  template = join(",", data.template_file.peerlink-accepter-one.*.rendered)
}

data "template_file" "routetable-accepter-one" {
  count    = local.routetable-size
  template = count.index
}

data "template_file" "routetable-accepter-two" {
  count    = length(data.template_file.routetable-accepter-one.*.rendered)
  template = join(",",slice(split(",", replace(join(",", local.baselist), "A", data.template_file.routetable-accepter-one.*.rendered[count.index])), 0, local.peerlink-accepter-size))
}
