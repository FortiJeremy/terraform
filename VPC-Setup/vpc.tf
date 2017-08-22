#./vpc/main.tf
# this module builds the base VPC and subnets

provider "aws" { region = "${var.region}" }

# lookup AZ map
data "aws_availability_zones" "az-available" {}

# Creates the Virtual Private Cloud
resource "aws_vpc" "main" {
	cidr_block = "${var.vpc_cidr}"

	tags {
		Name = "${var.stack_name}-VPC"
		stack_name = "${var.stack_name}"
	}
}

# apply an internet gateway to the vpc
resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.main.id}"
}

# Creates the 2 external and 2 internal subnets
resource "aws_subnet" "externalA" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.public_subnet1}"
	availability_zone = "${data.aws_availability_zones.az-available.names[0]}"
	map_public_ip_on_launch = "true"
	tags {
		Name = "External-A"
		stack_name = "${var.stack_name}"
	}
}

resource "aws_subnet" "externalB" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.public_subnet2}"
	availability_zone = "${data.aws_availability_zones.az-available.names[1]}"
	map_public_ip_on_launch = "true"
	tags {
		Name = "External-B"
		stack_name = "${var.stack_name}"
	}
}

resource "aws_subnet" "internalA" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.private_subnet1}"
	availability_zone = "${data.aws_availability_zones.az-available.names[0]}"
	tags {
		Name = "Internal-A"
		stack_name = "${var.stack_name}"
	}
}

resource "aws_subnet" "internalB" {
	vpc_id = "${aws_vpc.main.id}"
	cidr_block = "${var.private_subnet2}"
	availability_zone = "${data.aws_availability_zones.az-available.names[1]}"
	tags {
		Name = "Internal-B"
		stack_name = "${var.stack_name}"
	}
}

resource "aws_route_table" "public_rt" {
	vpc_id = "${aws_vpc.main.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}

	tags {
		Name = "External Subnets"
		stack_name = "${var.stack_name}"
	}
}

resource "aws_route_table_association" "public_rt1" {
	subnet_id = "${aws_subnet.externalA.id}"
	route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_rt2" {
	subnet_id = "${aws_subnet.externalB.id}"
	route_table_id = "${aws_route_table.public_rt.id}"
}

output "new" {
	value = "${data.aws_availability_zones.az-available.names}"
}
output "vpc" {
	value = "${aws_vpc.main.id}"
}

output "pubrt" {
	value = "${aws_route_table.public_rt.id}"
}

output "public_subnet1" {
	value = "${aws_subnet.externalA.id}"
}

output "public_subnet2" {
	value = "${aws_subnet.externalB.id}"
}

output "private_subnet1" {
	value = "${aws_subnet.internalA.id}"
}

output "private_subnet2" {
	value = "${aws_subnet.internalB.id}"
}


