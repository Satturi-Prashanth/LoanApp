# Application Load Balancer (external)
health_check {
path = "/"
matcher = "200-399"
}
}


resource "aws_lb_listener" "http" {
load_balancer_arn = aws_lb.external_alb.arn
port = "80"
protocol = "HTTP"
default_action {
type = "forward"
target_group_arn = aws_lb_target_group.web_tg.arn
}
}


# Launch template for web servers
resource "aws_launch_template" "web_lt" {
name_prefix = "${var.project}-web-"
image_id = data.aws_ami.amazon_linux.id
instance_type = "t3.micro"
key_name = var.key_name
vpc_security_group_ids = [aws_security_group.web_sg.id]
iam_instance_profile {
name = aws_iam_instance_profile.ec2_profile.name
}
user_data = base64encode("#!/bin/bash\necho 'hello web' > /var/www/html/index.html")
}


data "aws_ami" "amazon_linux" {
most_recent = true
owners = ["amazon"]
filter {
name = "name"
values = ["amzn2-ami-hvm-*-x86_64-gp2"]
}
}


# Auto Scaling Group (web)
resource "aws_autoscaling_group" "web_asg" {
name = "${var.project}-web-asg"
launch_template {
id = aws_launch_template.web_lt.id
version = "$Latest"
}
min_size = 1
max_size = 3
vpc_zone_identifier = values(aws_subnet.public)[*].id
target_group_arns = [aws_lb_target_group.web_tg.arn]
health_check_type = "ELB"
tags = [
{
key = "Name"
value = "${var.project}-web"
propagate_at_launch = true
}
]
}