locals {
  txgw_routes = flatten([
  for rt in var.transit_gateway_routes : [
    for rtid in aws_route_table.privrt : {
      name        = "${rtid.id}-${rt}"
      route       = rt
      route_table = rtid.id
      }
    if var.transit_gateway_id != false]
  ])
 
 peerlink_accepter_routes = flatten([
  for rt in aws_route_table.privrt : [
    for key, value in var.peer_accepter : {
      name        = "${rt.id}-${replace(replace(element(split("|", value),1), "." , "-"), "/", "-")}" 
      route_table = rt.id
      conn_id     = element(split("|", value),0)
      cidr        = element(split("|", value),1)
      }
    ]
  ])

  peerlink_requester_routes = flatten([
  for rt in aws_route_table.privrt : [
    for key, value in var.peer_requester : {
      name            = "${rt.id}-${replace(replace(element(split("|", value),2), "." , "-"), "/", "-")}" 
      peer_link_name  = key
      route_table     = rt.id
      cidr            = element(split("|", value),2)
      }
    ]
  ])

  vpn_connection_routes = flatten([
    for vpn in keys(var.vpn_connections) : [
      for cidr in split("|",merge(var.default_vpn_connections, var.vpn_connections[vpn]).destination_cidr_blocks) : {
        name = vpn
        cidr = cidr
      }
    if merge(var.default_vpn_connections, var.vpn_connections[vpn]).destination_cidr_blocks != ""]
  ])

  num-availbility-zones = "${length(var.zones[var.region])}"
  subnet-order = coalescelist( var.subnet-order, keys(var.subnets))

  /* NOTE: Requires that pub is first */
  pub-subnet-ids = slice(aws_subnet.subnets.*.id, 0, local.num-availbility-zones)

  emptymaps = [{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]
  empty-subnet-tags = zipmap(local.subnet-order, slice(local.emptymaps, 0 ,length(local.subnet-order)))
  subnet-tags = merge(local.empty-subnet-tags,var.subnet-tags)
  
  resource_list = ["aws_vpc", "aws_vpn_gateway", "aws_subnet", "aws_network_acl", "aws_internet_gateway", "aws_cloudwatch_log_group", "aws_vpc_dhcp_options", "aws_route_table", "aws_route53_resolver_endpoint"]
  empty-resource-tags = zipmap(local.resource_list, slice(local.emptymaps, 0 ,length(local.resource_list)))
  resource-tags = merge(local.empty-resource-tags, var.resource-tags)

  basecount = ["0|A", "1|A", "2|A", "3|A", "4|A", "5|A", "6|A", "7|A", "8|A", "9|A", "10|A", "11|A", "12|A", "13|A", "14|A", "15|A", "16|A", "17|A", "18|A", "19|A", "20|A", "21|A", "22|A", "23|A", "24|A", "25|A", "26|A", "27|A", "28|A", "29|A", "30|A", "31|A", "32|A", "33|A", "34|A", "35|A", "36|A", "37|A", "38|A", "39|A", "40|A", "41|A", "42|A", "43|A", "44|A", "45|A", "46|A", "47|A", "48|A", "49|A", "50|A", "51|A", "52|A", "53|A", "54|A", "55|A", "56|A", "57|A", "58|A", "59|A", "60|A", "61|A", "62|A", "63|A", "64|A", "65|A", "66|A", "67|A", "68|A", "69|A", "70|A", "71|A", "72|A", "73|A", "74|A", "75|A", "76|A", "77|A", "78|A", "79|A", "80|A", "81|A", "82|A", "83|A", "84|A", "85|A", "86|A", "87|A", "88|A", "89|A", "90|A", "91|A", "92|A", "93|A", "94|A", "95|A", "96|A", "97|A", "98|A", "99|A", "100|A", "101|A", "102|A", "103|A", "104|A", "105|A", "106|A", "107|A", "108|A", "109|A", "110|A", "111|A", "112|A", "113|A", "114|A", "115|A", "116|A", "117|A", "118|A", "119|A", "120|A", "121|A", "122|A", "123|A", "124|A", "125|A", "126|A", "127|A", "128|A", "129|A", "130|A", "131|A", "132|A", "133|A", "134|A", "135|A", "136|A", "137|A", "138|A", "139|A", "140|A", "141|A", "142|A", "143|A", "144|A", "145|A", "146|A", "147|A", "148|A", "149|A", "150|A", "151|A", "152|A", "153|A", "154|A", "155|A", "156|A", "157|A", "158|A", "159|A", "160|A", "161|A", "162|A", "163|A", "164|A", "165|A", "166|A", "167|A", "168|A", "169|A", "170|A", "171|A", "172|A", "173|A", "174|A", "175|A", "176|A", "177|A", "178|A", "179|A", "180|A", "181|A", "182|A", "183|A", "184|A", "185|A", "186|A", "187|A", "188|A", "189|A", "190|A", "191|A", "192|A", "193|A", "194|A", "195|A", "196|A", "197|A", "198|A", "199|A", "200|A", "201|A", "202|A", "203|A", "204|A", "205|A", "206|A", "207|A", "208|A", "209|A", "210|A", "211|A", "212|A", "213|A", "214|A", "215|A", "216|A", "217|A", "218|A", "219|A", "220|A", "221|A", "222|A", "223|A", "224|A", "225|A", "226|A", "227|A", "228|A", "229|A", "230|A", "231|A", "232|A", "233|A", "234|A", "235|A", "236|A", "237|A", "238|A", "239|A", "240|A", "241|A", "242|A", "243|A", "244|A", "245|A", "246|A", "247|A", "248|A", "249|A", "250|A", "251|A", "252|A", "253|A", "254|A", "255|A", "256|A", "257|A", "258|A", "259|A", "260|A", "261|A", "262|A", "263|A", "264|A", "265|A", "266|A", "267|A", "268|A", "269|A", "270|A", "271|A", "272|A", "273|A", "274|A", "275|A", "276|A", "277|A", "278|A", "279|A", "280|A", "281|A", "282|A", "283|A", "284|A", "285|A", "286|A", "287|A", "288|A", "289|A", "290|A", "291|A", "292|A", "293|A", "294|A", "295|A", "296|A", "297|A", "298|A", "299|A", "300|A"]
  baselist = ["A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A","A",]
  azs-size = local.num-availbility-zones
  subnets-size = length(var.subnets)
  azs-list = split(",", join(",", data.template_file.azs-two.*.rendered))
  subnets-list = (split(",", join(",", data.template_file.subnets-two.*.rendered)))


  route53-zones = split(",", join(",", data.template_file.subnet-24s-lists.*.rendered))

  peerlink-size = length(var.peer_requester)
  routetable-size = length(var.zones[var.region])
  peerlink-list = split(",", join(",", data.template_file.peerlink-two.*.rendered))
  routetable-list = (split(",", join(",", data.template_file.routetable-two.*.rendered)))
  
  peerlink-accepter-size = length(var.peer_accepter)
  peerlink-accepter-list = split(",", join(",", data.template_file.peerlink-accepter-two.*.rendered))
  routetable-accepter-list = (split(",", join(",", data.template_file.routetable-accepter-two.*.rendered)))

  map_subnet_id_list = length(aws_subnet.subnets.*.id) == 0 ? {} : zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.id, local.num-availbility-zones))
  map_subnet_arn_list = length(aws_subnet.subnets.*.arn) == 0 ? {} : zipmap(var.subnet-order, chunklist(aws_subnet.subnets.*.arn, local.num-availbility-zones))
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
