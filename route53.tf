data "template_file" "subnet-24s-lists" {
  count    = length(var.vpc-cidrs)
  template = replace(join(",", slice(local.basecount, 0, data.template_file.subnet-24s-count.*.rendered[count.index])), "A", var.vpc-cidrs[count.index])
}

data "template_file" "subnet-24s-count" {
  count    = length(var.vpc-cidrs)
  template = pow(2,(24 - element(split("/", var.vpc-cidrs[count.index]), 1)))
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


data "template_file" "route53-test" {
  template = "${element(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids, count.index)}"
}


/*
resource "aws_route53_resolver_rule_association" "r53_resolver_rule_association"{
  count            = var.shared_resolver_rule ? length(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids) : 0
  resolver_rule_id = "${element(data.aws_route53_resolver_rules.shared_resolver_rule.*.resolver_rule_ids, count.index)}"
  vpc_id           = aws_vpc.main_vpc.id
}
*/