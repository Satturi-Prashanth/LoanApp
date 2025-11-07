# Web SG (for ALB and Web servers)
}
ingress {
from_port = 443
to_port = 443
protocol = "tcp"
cidr_blocks = [var.allowed_cidr]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}


resource "aws_security_group" "web_sg" {
name = "${var.project}-web-sg"
vpc_id = aws_vpc.main.id
description = "Allow inbound from ALB only"


ingress {
from_port = 80
to_port = 80
protocol = "tcp"
security_groups = [aws_security_group.alb_sg.id]
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}
}


resource "aws_security_group" "app_sg" {
name = "${var.project}-app-sg"
vpc_id = aws_vpc.main.id
description = "Allow inbound from web tier"
ingress {
from_port = 8080
to_port = 8080
protocol = "tcp"
security_groups = [aws_security_group.web_sg.id]
}
egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}


resource "aws_security_group" "db_sg" {
name = "${var.project}-db-sg"
vpc_id = aws_vpc.main.id
description = "Allow inbound from app tier to RDS"
ingress {
from_port = 5432
to_port = 5432
protocol = "tcp"
security_groups = [aws_security_group.app_sg.id]
}
egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}