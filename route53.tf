data "template_file" "subnet-24s-lists" {
  count    = length(var.vpc-cidrs)
  template = replace(join(",", slice(local.basecount, 0, pow(2,(24 - element(split("/", var.vpc-cidrs[count.index]), 1))))), "A", var.vpc-cidrs[count.index])
}

resource "aws_route53_zone" "reverse_zones" {
  count = var.default_reverse_zones ? length( local.route53-zones ) : 0
  name = "${element(split(".",element(split("/", cidrsubnet(element(split("|",local.route53-zones[count.index]), 1), (24 - element(split("/", element(split("|",local.route53-zones[count.index]), 1)), 1)), element(split("|",local.route53-zones[count.index]), 0))),0)),2)}.${element(split(".",element(split("/", cidrsubnet(element(split("|",local.route53-zones[count.index]), 1), (24 - element(split("/", element(split("|",local.route53-zones[count.index]), 1)), 1)), element(split("|",local.route53-zones[count.index]), 0))),0)),1)}.${element(split(".",element(split("/", cidrsubnet(element(split("|",local.route53-zones[count.index]), 1), (24 - element(split("/", element(split("|",local.route53-zones[count.index]), 1)), 1)), element(split("|",local.route53-zones[count.index]), 0))),0)),0)}.in-addr.arpa"
  vpc {
    vpc_id = aws_vpc.main_vpc.id
  }
}

data "aws_route53_resolver_rules" "shared_resolver_rule"{
  count        = var.shared_resolver_rule ? 1 : 0
  share_status = "SHARED_WITH_ME"
}

resource "aws_route53_resolver_rule_association" "r53_resolver_rule_association"{
  count            = var.shared_resolver_rule ? length(flatten(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids)) : 0
  resolver_rule_id = element(flatten(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids), count.index)
  vpc_id           = aws_vpc.main_vpc.id
}

# resource "aws_route53_resolver_rule_association" "r53_resolver_rule_association"{
#   count            = var.shared_resolver_rule ? length(flatten(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids)) : 0
#   for_each         =  
#   resolver_rule_id = (flatten(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids), count.index)
#   vpc_id           = aws_vpc.main_vpc.id
# }

resource "aws_security_group" "sg-r53ept-inbound" {
  count       = var.route53_resolver_endpoint || var.route53_outbound_endpoint ? 1 : 0
  name        = "r53ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  description = "Allows access to the Route52 Resolver Endpoiny"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "tcp"
    cidr_blocks = var.route53_resolver_endpoint_cidr_blocks
  }

  ingress {
    from_port = 53
    to_port   = 53
    protocol  = "udp"
    cidr_blocks = var.route53_resolver_endpoint_cidr_blocks
  }
 
  egress {
    description = "Allow all outbound"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.tags,
    map("Name",format("%s", "sg-r52ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" )),
    local.resource-tags["aws_route53_resolver_endpoint"]
  )
}

resource "aws_route53_resolver_endpoint" "resolver_endpoint" {
  count     = var.route53_resolver_endpoint ? 1 : 0
  name      = "r53ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  direction = "INBOUND"
  security_group_ids = aws_security_group.sg-r53ept-inbound.*.id

  dynamic "ip_address" {
    for_each = local.map_subnet_id_list[var.route53_resolver_endpoint_subnet]
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(
    var.tags,
    map("Name",format("%s", "sg-r52ept-inbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" )),
    local.resource-tags["aws_route53_resolver_endpoint"]
  )
}

resource "aws_route53_resolver_endpoint" "outbound_endpoint" {
  count     = var.route53_outbound_endpoint ? 1 : 0
  name      = "r53ept-outbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}"
  direction = "OUTBOUND"
  security_group_ids = aws_security_group.sg-r53ept-inbound.*.id

  dynamic "ip_address" {
    for_each = local.map_subnet_id_list[var.route53_resolver_endpoint_subnet]
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(
    var.tags,
    map("Name",format("%s", "sg-r53ept-outbound-${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}" )),
    local.resource-tags["aws_route53_resolver_endpoint"]
  )
}

resource "aws_route53_resolver_rule" "resolver_rule" {
  count                = var.route53_outbound_endpoint ? length(var.forward_rules) : 0
  domain_name          = lookup(var.forward_rules[count.index], "domain_name")
  name                 = replace(lookup(var.forward_rules[count.index], "domain_name"),".","_")
  rule_type            = lookup(var.forward_rules[count.index], "rule_type")
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound_endpoint.0.id

  target_ip {
    ip = element(split(",", lookup(var.forward_rules[count.index]["ips"], var.region, var.forward_rules[count.index]["ips"]["us-east-1"])),0)
  }
  target_ip {
    ip = element(split(",", lookup(var.forward_rules[count.index]["ips"], var.region, var.forward_rules[count.index]["ips"]["us-east-1"])),1)
  }

  tags = var.tags
}

resource "aws_route53_resolver_rule_association" "r53_outbound_rule_association"{
  count            = var.route53_outbound_endpoint ? length(flatten(aws_route53_resolver_rule.resolver_rule.*.id)) : 0
  resolver_rule_id = element(flatten(aws_route53_resolver_rule.resolver_rule.*.id), count.index)
  vpc_id           = aws_vpc.main_vpc.id
}
