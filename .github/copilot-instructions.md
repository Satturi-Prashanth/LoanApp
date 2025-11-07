## Repo overview

This repository is an AWS infrastructure Terraform configuration for a small web application. It provisions a VPC with public/private subnets, NAT gateways, an external ALB + target group, an Auto Scaling Group of EC2 web servers (via a Launch Template), an application tier security model, RDS (Postgres), CloudFront + Route53, S3 for assets and logs, CloudTrail, VPC flow logs and basic CloudWatch/SNS alerting.

Key files to read first

- `provider.tf` — Terraform provider/version requirements (Terraform >=1.0, aws provider ~>5.0).
- `Networking.tf` — VPC, subnets, route tables, NAT gateways and EIP per public subnet.
- `security_groups.tf` — Security group design and inbound relationships (alb -> web -> app -> db).
- `alb_sg.tf` — ALB, target group, listeners, Launch Template, and Auto Scaling Group.
- `rds.tf` — RDS subnet group and instance (Postgres, multi-AZ, skip_final_snapshot = true).
- `cloudfront_route53.tf` — CloudFront distribution and optional Route53 alias.
- `s3_cloudtrail.tf` — S3 buckets used for flow logs and CloudTrail.
- `iam.tf` — EC2 IAM role / instance profile used by the Launch Template.
- `variables.tf` and `outputs.tf` — Repo-level defaults and exported outputs.

What matters (big picture)

- Naming and tagging: nearly every resource uses `var.project` as a prefix (e.g. `${var.project}-web-sg`). Respect this convention when adding resources.
- Network design: public subnets contain NAT gateways and ALB; private subnets house RDS and app servers. NATs are created per public subnet and wired into a single private route table.
- Security groups are layered and reference other SG IDs (not CIDR) for intra-tier rules. Example: `web_sg` allows port 80 from `alb_sg`, `app_sg` allows 8080 from `web_sg`, `db_sg` allows 5432 from `app_sg`.
- Compute: web servers are launched via `aws_launch_template` with an `aws_autoscaling_group` attached to an ALB target group. ASG health checks are ELB-based.
- Storage and logging: flow logs and CloudTrail go to S3 (random_id used to generate unique bucket names).

Project-specific conventions and gotchas

- Sensitive values: `rds_password` is `sensitive = true` and intentionally has no default. Provide via `terraform.tfvars` or environment variable `TF_VAR_rds_password`.
- Defaults: many variables have defaults (e.g. `aws_region` = `us-east-1`, `allowed_cidr` = `0.0.0.0/0`). Review and override for non-prod security.
- Resource naming: random IDs (via `random_id`) are used for S3 buckets to avoid collisions — changing/removing them will change resource names in-state.
- RDS destroy behavior: `skip_final_snapshot = true` — destroying will not keep a final snapshot. Be cautious in production.
- CloudFront <> ALB mismatch: CloudFront origin is configured with `origin_protocol_policy = "https-only"` while the ALB listener in `alb_sg.tf` exposes only HTTP (port 80). This will likely fail at runtime (CloudFront expects HTTPS on the origin). Either add an HTTPS listener / certificate to the ALB or change the CloudFront origin protocol to `http-only`.

Common workflows / commands (PowerShell examples)

1) Initialize and install providers

```powershell
terraform init
```

2) Plan using a tfvars file (recommended for secrets)

```powershell
terraform plan -var-file="terraform.tfvars"
```

3) Apply

```powershell
terraform apply -var-file="terraform.tfvars"
```

4) Inspection & debugging

- `terraform state list` and `terraform state show <resource>` to inspect created resources.
- Check ALB target group health (health_check path `/`, matcher `200-399`) if instances are drained or unhealthy.
- Use `aws` CLI or console to check CloudFront origin-request logs, ALB listeners, and EC2 console logs for user_data (`/var/www/html/index.html` is created by the launch template).

Patterns and examples to reference when changing code

- Prefix new resource names and tags with `${var.project}-...` to match existing naming. Example: `Name = "${var.project}-web"` in ASG tags.
- When opening inbound ports between tiers, reference security group IDs, not CIDR ranges. E.g. `security_groups = [aws_security_group.alb_sg.id]`.
- Use `values(aws_subnet.public)[*].id` pattern for lists of subnet IDs (seen across networking, ASG, and RDS subnet group).

Secrets and CI considerations

- Do not hardcode `rds_password` or emails (see `monitoring_sns.tf` uses `ops-team@example.com` as a placeholder). Use CI secrets or `terraform.tfvars` excluded from VCS.

What an agent should do first

1. Read `provider.tf`, `variables.tf`, `Networking.tf`, and `security_groups.tf` to understand the network and security model.
2. Validate CloudFront <> ALB origin settings and flag whether to add an ALB HTTPS listener or change the CloudFront origin protocol.
3. For any change that affects resource identity (buckets, launch templates, random_id), note migration/state implications and show exact terraform commands to safely migrate.

If anything is unclear or you want me to expand any section (workflows, CI, or a migration checklist), tell me which area and I will iterate.
