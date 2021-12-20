##################################################
# File: flowlogs.tf                              #
# Created Date: 03092019                         #
# Author: Fred Stuck                             #
# Version: 0.1                                   #
# Description: Sets up flow logs                 #
#                                                #
# Change History:                                #
# 03092019: Initial File                         #
#                                                #
##################################################

/*
resource "aws_flow_log" "vpc_flowlog" {
  count = var.enable_flowlog ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  log_destination = aws_cloudwatch_log_group.flowlog_group.0.arn
  iam_role_arn = aws_iam_role.flowlog_role.0.arn
  traffic_type = "ALL"
  log_format = var.flow_log_format
}
*/

resource "aws_flow_log" "vpc_flowlog" {
  count = var.enable_flowlog ? 1 : 0
  vpc_id                   = aws_vpc.main_vpc.id
  log_destination          = local.flow_log_destination_arn
  iam_role_arn             = local.flow_log_iam_role_arn
  traffic_type             = var.flow_log_traffic_type
  max_aggregation_interval = var.flow_log_max_aggregation_interval
  log_format               = var.flow_log_format
  log_destination_type     = var.flow_log_destination_type

  dynamic "destination_options" {
    for_each = var.flow_log_destination_type == "s3" ? [var.region] : []
    content {
      file_format                = var.flow_log_file_format
      hive_compatible_partitions = var.flow_log_hive_compatible_partitions
      per_hour_partition         = var.flow_log_per_hour_partition
    }
  }
}



resource "aws_cloudwatch_log_group" "flowlog_group" {
  count = var.enable_flowlog && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name = aws_vpc.main_vpc.id
  retention_in_days = var.cloudwatch_retention_in_days
  tags = merge(
    var.tags,
    map("Name","${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-log"),
    local.resource-tags["aws_cloudwatch_log_group"]
    )
}

resource "aws_iam_role" "flowlog_role" {
  count = var.enable_flowlog && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-flow-log-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
} 
EOF
}

resource "aws_iam_role_policy" "flowlog_write" {
  count = var.enable_flowlog && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name = "${var.name-vars["account"]}-${replace(var.region,"-", "")}-${var.name-vars["name"]}-write-to-cloudwatch"
  role = aws_iam_role.flowlog_role.0.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}   
EOF
}

/* Lambda */
resource "aws_cloudwatch_log_subscription_filter" "flow_logs_lambda" {
  count = var.enable_flowlog && !(var.aws_lambda_function_name == "null") && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  name = "${var.aws_lambda_function_name}-logfilter"
  log_group_name = aws_cloudwatch_log_group.flowlog_group.0.name
  filter_pattern = var.flow_log_filter
  destination_arn = "arn:aws:lambda:${var.region}:${var.acctnum}:function:${var.aws_lambda_function_name}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count          = var.enable_flowlog && !(var.aws_lambda_function_name == "null" ) && var.flow_log_destination_type == "cloud-watch-logs" ? 1 : 0
  statement_id   = "AllowExecutionFromCloudWatch_${aws_vpc.main_vpc.id}"
  action         = "lambda:InvokeFunction"
  function_name  = var.aws_lambda_function_name
  principal      = "logs.${var.region}.${var.amazonaws-com}"
  source_account = var.acctnum
  source_arn     = length(regexall(".*cn-.*", var.region)) > 0 ? "arn:aws-cn:logs:${var.region}:${var.acctnum}:log-group:${aws_vpc.main_vpc.id}:*" : "arn:aws:logs:${var.region}:${var.acctnum}:log-group:${aws_vpc.main_vpc.id}:*"
}
