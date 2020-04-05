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

variable "subnets-tags" {
  type = map(map(string))
  description = "Optional : A map of maps of tags to assign to specifc subnet resource."
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
  description = "Optional : Keys are used for subnet names and values are the list of subnets for each AZ. The number of subnets specified in each list needs to match the number of AZs. 'pub' is the only special name used for the public subnet and must be specified first."
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
  default = ["10.0.0.0/8|22"]
}

variable "bypass_egress_rules" {
  description = "Optional : Permit egress Source|Port or Source|StartPort-EndPort for example 10.0.0.0/8|22 or 10.0.0.0/8|20-21"
  type = list(string)
  default = []
}

variable "block_ports" {
  description = "Optional : Ports to block both inbound and outbound"
  type = list(string)
  default = ["20-21", "23", "137-139", "445", "1433", "1521", "3306", "3389", "5439", "5432"]
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

variable "dx_gateway_id" {
  description = "Optional : specify the Direct Connect Gateway ID to associate the VGW with."
  default     = false
}

variable "transit_gateway_id" {
  description = "Optional : specify the Transit Gateway ID within the same account to associate the VPC with."
  default     = false
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

variable "private_endpoints_subnet" {
  description = "The subnet to install private endpoints, the default is mgt."
  default = "mgt"
}

variable "private_endpoints" {
  description = "List of private AWS Endpoints - <REGION> will be replace with the region of the VPC. This helps standardize inputs between VPCs for example you can send com.amazonaws.<REGION>.cloudformation for a cloudformation endpoint."
  default = []
}

variable "private_endpoints_security_group" {
  description = "List of security groups IDs to apply to each AWS Endpoint. The list should be the same length as private_endpoints. If multiple security are required for an individual endpoint delemit each with a pipe (|)."
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
  default = "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action, flowlogstatus]"
}

variable "cloudwatch_retention_in_days" {
  description = "Optional : Number of days to keep logs within the cloudwatch log_group. The default is 7 days."
  default = "7"
}

variable "amazonaws-com" {
  description = "Optional : Ability to change principal for flowlogs from amazonaws.com to amazonaws.com.cn."
  default = "amazonaws.com"
}