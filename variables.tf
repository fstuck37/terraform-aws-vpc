variable "region" {
  type = string
  description = "Required : The AWS Region to deploy the VPC to"
}

variable "vpc-cidrs" {
  description = "Required : List of CIDRs to apply to the VPC."
  type = list(string)
  default = ["10.0.0.0/21"]
}

variable "acctnum" {
  description = "Required : AWS Account Number"
}

variable "name-vars" {
  description = "Required : Map with two keys account and name. Names of elements are created based on these values."
  type = map(string)
}

variable "tags" {
  type = map(string)
  description = "Optional : A map of tags to assign to the resource."
  default = {}
}

variable "subnet-tags" {
  type = map(map(string))
  description = "Optional : A map of maps of tags to assign to specifc subnet resource.  The key but be the same as the key in variable subnets."
  default = { }
}

variable "resource-tags" {
  type = map(map(string))
  description = "Optional : A map of maps of tags to assign to specifc resources.  The key must be one of the following: aws_vpc, aws_vpn_gateway, aws_subnet, aws_network_acl, aws_internet_gateway, aws_cloudwatch_log_group, aws_vpc_dhcp_options, aws_route_table."
  default = { }
}


/* VPC Variables */
variable "vpc-name" {
  description = "Optional : Override the calculated VPC name"
  default     = true
}

variable "enable_dns_support" {
  description = "Optional : A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Optional : A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default     = true
}

variable "default_reverse_zones" {
  description = "Optional : Deploy Route53 Reverse Lookup Zones as /24s. Defaults to false"
  default     = false
}

variable "shared_resolver_rule" {
  description = "Optional : Deploy Route53 resolver rules. Defaults to false"
  default     = false
}

variable "exclude_resolver_rule_ids" {
  description = "Optional : A list of resolve rule IDs to exclude from the resolve rule associations."
  type        = list(string)
  default     = []
}

variable "route53_resolver_endpoint" {
  type = string
  description = "Optional : A boolean flag to enable/disable Route53 Resolver Endpoint. Defaults false."
  default = false
}

variable "route53_resolver_endpoint_cidr_blocks" {
  type = list(string)
  description = "Optional : A list of the source CIDR blocks to allow to commuicate with the Route53 Resolver Endpoint. Defaults 0.0.0.0/0."
  default = ["0.0.0.0/0"]
}

variable "route53_resolver_endpoint_subnet" {
  type = string
  description = "Optional : The subnet to install Route53 Resolver Endpoint , the default is mgt but must exist as a key in the variable subnets."
  default = "mgt"
}
variable "route53_outbound_endpoint" {
  type = string
  description = "Optional : A boolean flag to enable/disable Route53 Outbound Endpoint. Defaults false."
  default = false
}
variable "forward_rules" {
  type = list
  description = "List of Forward Rules"
  default = []
}

variable "instance_tenancy" {
  type        = string
  description = "Optional : A tenancy option for instances launched into the VPC."
  default     = "default"
}

/* Subnet Variables */
variable "subnets" {
  type = map(string)
  description = "Optional : Keys are used for subnet names and values are the subnets for the various layers. These will be divided by the number of AZs based on ceil(log(length(var.zones[var.region]),2)). 'pub' is the only special name used for the public subnet and must be specified first."
  default = {
    pub = "10.0.0.0/24"
    web = "10.0.1.0/24"
    app = "10.0.2.0/24"
    db  = "10.0.3.0/24"
    mgt = "10.0.4.0/24"
  }
}

variable "fixed-subnets" {
  type = map(list(string))
  description = "Optional : Keys must match subnet-order and values are the list of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used."
  default = { }
}

variable "fixed-name" {
  type = map(list(string))
  description = "Optional : Keys must match subnet-order and values are the name of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used."
  default = { }
}

variable "subnet-order" {
  type = list(string)
  description = "Required : Order in which subnets are created. Changes can cause recreation issues when subnets are added when something precedes other subnets. Must include all key names."
}

/* DHCP options */
variable "domain_name" {
  description = "Optional : DNS search domains for DHCP Options"
  default = "ec2.internal"
}

variable "domain_name_servers" {
  description = "Optional : DNS Servers for DHCP Options"
  default = ["AmazonProvidedDNS"]
}

variable "ntp_servers" {
  description = "Optional : NTP Servers for DHCP Options"
  default = []
}

/* Start Network ACL Variables */
variable "bypass_ingress_rules" {
  description = "Optional : Permit ingress Source|Port or Source|StartPort-EndPort for example 10.0.0.0/8|22 or 10.0.0.0/8|20-21"
  type = list(string)
  default = []
}

variable "bypass_egress_rules" {
  description = "Optional : Permit egress Source|Port or Source|StartPort-EndPort for example 10.0.0.0/8|22 or 10.0.0.0/8|20-21"
  type = list(string)
  default = []
}

variable "block_ports" {
  description = "Optional : Ports to block both inbound and outbound"
  type = list(string)
  default = ["20-21", "22", "23", "137-139", "445", "1433", "1521", "3306", "3389", "5439", "5432"]
}

variable "ingress_block" {
  description = "Optional : CIDR blocks to block inbound"
  type = list(string)
  default = []
}

variable "egress_block" {
  description = "Optional : CIDR blocks to block outbound"
  type = list(string)
  default = []
}

/* Direct Connect Gateway */
variable "dx_bgp_default_route" {
  description = "Optional : A boolean flag that indicates that the default gateway will be advertised via bgp over Direct Connect and causes the script to not deploy NAT Gateways."
  default     = false
}

variable "enable_pub_route_propagation" {
  description = "Optional : A boolean flag that indicates that the routes should be propagated to the pub routing table. Defaults to False."
  default     = false
}

variable "dx_gateway_id" {
  description = "Optional : specify the Direct Connect Gateway ID to associate the VGW with."
  default     = false
}

variable "transit_gateway_id" {
  description = "Optional : specify the Transit Gateway ID within the same account to associate the VPC with."
  default     = false
}

variable "appliance_mode_support" {
  description = "(Optional) Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: disable, enable. Default value: disable."
  default     = "disable"
}

variable "transit_gateway_routes" {
  type = list(string)
  description = "Optional : specify the networks to route to the Transit Gateway"
  default     = []
}

/* Endpoint Configuration */

variable "enable-s3-endpoint" {
  description = "Optional : Enable the S3 Endpoint"
  default     = false
}

variable "enable-dynamodb-endpoint" {
  description = "Optional : Enable the DynamoDB Endpoint"
  default     = false
}

variable "private_endpoints" {
description = "List of Maps for private AWS Endpoints Keys: name[Name of Resource IE: s3-endpoint], subnet[Name of the subnet group for the Endpoint IE: web], service[The Service IE: com.amazonaws.<REGION>.execute-api, <REGION> will be replaced with VPC Region], security_group[sg id to apply, if more than one is needed they should be | delimited]"
  default = []
}

/* Peer Links */
variable "peer_requester" {
  description = "Optional : Map of Peer Link Name with a value of [Peer AWS Account Number]|[Peer VPC_ID]|[Peer VPC CIDR]|[allow_remote_vpc_dns_resolution]. This only creates the requester half of the connection. Since maps our lexically prepend the VPC name with a alpha character so they flow alphabetically, for example a-peerlink1, b-peerlink2, etc."
  type = map(string)
  default = {}
}

variable "peer_accepter" {
  description = "Optional : Map of Peer Link Name with a value of [vpc_peering_connection_id]|[Peer VPC CIDR]. This only creates the accepter half of the connection. Since maps our lexically prepend the VPC name with a alpha character so they flow alphabetically, for example a-peerlink1, b-peerlink2, etc."
  type = map(string)
  default = {}
}

/* NAT Gateway */
variable "deploy_natgateways" {
  description = "Optional : Set to true to deploy NAT gateways if pub subnet is created"
  default = false
}

/* VPC Flow Logs */
variable "enable_flowlog" {
  description = "Optional : A boolean flag to enable/disable VPC flowlogs."
  default     = false
}

variable "aws_lambda_function_name" {
  description = "Optional : Lambda function name to call when sending to logs to an external SEIM."
  default = "none"
}

variable "flow_log_filter" {
  description = "CloudWatch subscription filter to match flow logs."
  default     = ""
}

variable "flow_log_format" {
  description = "VPC flow log format."
  default = "$${version} $${account-id} $${interface-id} $${srcaddr} $${dstaddr} $${srcport} $${dstport} $${protocol} $${packets} $${bytes} $${start} $${end} $${action} $${log-status} $${vpc-id} $${subnet-id} $${instance-id} $${tcp-flags} $${type} $${pkt-srcaddr} $${pkt-dstaddr} $${region} $${az-id} $${sublocation-type} $${sublocation-id} $${pkt-src-aws-service} $${pkt-dst-aws-service} $${flow-direction} $${traffic-path}"
}

variable "cloudwatch_retention_in_days" {
  description = "Optional : Number of days to keep logs within the cloudwatch log_group. The default is 7 days."
  default = "7"
}

variable "amazonaws-com" {
  description = "Optional : Ability to change principal for flowlogs from amazonaws.com to amazonaws.com.cn."
  default = "amazonaws.com"
}

/* Site-to-Site VPN Connections */
variable "vpn_connections" {
  type = map(map(string))
  description = "Optional : A map of a map with the settings for each VPN.  The key will be the name of the VPN"
  default = { }
}


variable "default_vpn_connections" {
  type = map(string)
  description = "Do not use: This defines the default values for each map entry in vpn_connections. Do not override this."
  default = { 
      static_routes_only = false
      destination_cidr_blocks = ""
      tunnel1_inside_cidr = null
      tunnel1_preshared_key = null
      tunnel2_inside_cidr = null
      tunnel2_preshared_key = null
  }
}

variable "egress_only_internet_gateway" {
  description = "Optional : Deploy egress_only_internet_gateway instead of aws_internet_gateway"
  default     = false
}

/* Setup Gateway Load Balancer Endpoint */
variable "deploy_gwep" {
  description = "Optional : Setup Gateway Load Balancer Endpoint components"
  default = false
}

variable "gwep_subnet" {
  description = "Optional : CIDR Blocked used for the Gateway Endpoints"
  default = ""
}

variable "gwep_service_name" {
  description = "Optional : Service Name for Gateway Endpoint"
  default = ""
}

