# S3 bucket for website origin (optional)
domain_name = aws_lb.external_alb.dns_name
origin_id = "alb-origin"
custom_origin_config {
http_port = 80
https_port = 443
origin_protocol_policy = "https-only"
origin_ssl_protocols = ["TLSv1.2"]
}
}


enabled = true
is_ipv6_enabled = true


default_cache_behavior {
allowed_methods = ["GET", "HEAD", "OPTIONS"]
cached_methods = ["GET", "HEAD"]
target_origin_id = "alb-origin"
forwarded_values { query_string = false }
viewer_protocol_policy = "redirect-to-https"
min_ttl = 0
default_ttl = 3600
max_ttl = 86400
}


restrictions {
geo_restriction { restriction_type = "none" }
}


viewer_certificate {
cloudfront_default_certificate = true
}


tags = { Name = "${var.project}-cdn" }
}


# Route53 record (assumes hosted zone exists)
variable "hosted_zone_id" {
type = string
default = "" # set in tfvars
}


variable "record_name" {
type = string
default = ""
}


resource "aws_route53_record" "www" {
count = length(var.hosted_zone_id) > 0 && length(var.record_name) > 0 ? 1 : 0
zone_id = var.hosted_zone_id
name = var.record_name
type = "A"
alias {
name = aws_cloudfront_distribution.cdn.domain_name
zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
evaluate_target_health = false
}
}