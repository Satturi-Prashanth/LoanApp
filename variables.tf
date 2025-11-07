variable "aws_region" {
type = string
default = "us-east-1"
}


variable "project" {
type = string
default = "founda-app"
}


variable "vpc_cidr" {
type = string
default = "10.0.0.0/16"
}


variable "public_subnets" {
type = list(string)
default = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnets" {
type = list(string)
default = ["10.0.11.0/24", "10.0.12.0/24"]
}


variable "azs" {
type = list(string)
default = ["${var.aws_region}a", "${var.aws_region}b"]
}


variable "key_name" {
type = string
default = "my-key"
}


variable "allowed_cidr" {
type = string
default = "0.0.0.0/0"
}


variable "rds_username" {
type = string
default = "founda_user"
}


variable "rds_password" {
type = string
description = "Set via tfvars or environment — do not store plaintext"
type = string
sensitive = true
}