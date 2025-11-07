output "vpc_id" {
value = aws_vpc.main.id
}


output "alb_dns" {
value = aws_lb.external_alb.dns_name
}


output "cloudfront_domain" {
value = aws_cloudfront_distribution.cdn.domain_name
}


output "rds_endpoint" {
value = aws_db_instance.primary.address
sensitive = true
}