resource "aws_db_subnet_group" "rds_subnets" {
name = "${var.project}-db-subnet-group"
subnet_ids = values(aws_subnet.private)[*].id
tags = { Name = "${var.project}-db-subnet-group" }
}


resource "aws_db_instance" "primary" {
identifier = "${var.project}-db-primary"
engine = "postgres"
instance_class = "db.t3.micro"
allocated_storage = 20
name = "foundadb"
username = var.rds_username
password = var.rds_password
skip_final_snapshot = true
db_subnet_group_name = aws_db_subnet_group.rds_subnets.name
vpc_security_group_ids = [aws_security_group.db_sg.id]
multi_az = true
tags = { Name = "${var.project}-rds-primary" }
}