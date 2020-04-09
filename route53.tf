data "template_file" "subnet-24s-lists" {
  count    = length(var.vpc_cidrs)
  template = replace(join(",", slice(local.basecount, data.template_file.subnet-24s-count.*.rendered[count.index])), "A", var.cidrs[count.index])
}

data "template_file" "subnet-24s-count" {
  count    = length(var.vpc_cidrs)
  template = pow(2,(24 - element(split("/", var.vpc_cidrs[count.index]), 1)))
}


/*

resource "aws_route53_zone" "reverse_zones" {
  for_each = zipmap(var.vpc_cidrs, var.vpc_cidrs)
    count = var.default_reverse_zones ? pow(2,(24 - element(split("/", each.key), 1))) :0 
    name  = "${element(split(".",element(split("/", cidrsubnet(each.key, (24 - element(split("/", each.key), 1)), count.index)),0)),2)}.${element(split(".",element(split("/", cidrsubnet(each.key, (24 - element(split("/", each.key), 1)), count.index)),0)),1)}.${element(split(".",element(split("/", cidrsubnet(each.key, (24 - element(split("/", each.key), 1)), count.index)),0)),0)}.in-addr.arpa"
    vpc {
      vpc_id = aws_vpc.main_vpc.id
    }
}


data "aws_route53_resolver_rules" "shared_resolver_rule"{
  count        = var.shared_resolver_rule ? 1 : 0
  share_status = "SHARED_WITH_ME"
}

resource "aws_route53_resolver_rule_association" "rule_association_0"{
  count            = var.shared_resolver_rule ? length(data.aws_route53_resolver_rules.shared_resolver_rule.resolver_rule_ids) : 0
  resolver_rule_id = element(data.aws_route53_resolver_rules.shared_resolver_rule.resolver_rule_ids, count.index)
  vpc_id           = aws_vpc.main_vpc.id
}

*/