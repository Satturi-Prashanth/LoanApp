resource "aws_s3_bucket" "flow_logs" {
bucket = "${var.project}-vpc-flow-logs-${random_id.bucket_id.hex}"
acl = "private"
force_destroy = true
tags = { Name = "${var.project}-flow-logs" }
}


resource "random_id" "bucket_id" {
byte_length = 4
}


# CloudTrail to the S3 bucket
resource "aws_cloudtrail" "trail" {
name = "${var.project}-trail"
s3_bucket_name = aws_s3_bucket.flow_logs.id
include_global_service_events = true
is_multi_region_trail = true
enable_log_file_validation = false
}


# VPC Flow Logs to S3
resource "aws_flow_log" "vpc_flow" {
log_destination_type = "s3"
traffic_type = "ALL"
vpc_id = aws_vpc.main.id
log_destination = aws_s3_bucket.flow_logs.arn
}