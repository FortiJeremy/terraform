# ./vpc/variables.tf	Last Modified 2017-08-17
# Declare variable for all region specific calls
variable "region" {
	description = "EC2 Region for VPC"
	default = "us-east-1"
}
variable "vpc_cidr" {
	description = "CIDR for entire VPC"
	default = "10.0.0.0/16"
}

variable "public_subnet1" {
	description = "CIDR for Public Subnet AZ1"
	default = "10.0.0.0/24"
}

variable "public_subnet2" {
	description = "CIDR for Public Subnet AZ2"
	default = "10.0.1.0/24"
}

variable "private_subnet1" {
	description = "CIDR for private subnet AZ1"
	default = "10.0.128.0/24"
}

variable "private_subnet2" {
	description = "CIDR for private subnet AZ1"
	default = "10.0.129.0/24"
}

variable "stack_name" {
	description = "Name for the VPC Stack"
	type = "string"
	default = "ftnt-test"
}
