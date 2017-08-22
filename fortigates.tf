# ./fortigates.tf   Last Modified 2017-08-18
# This requires the fortigate-ondemand and VPC-Setup module to properly 
# deploy. This should load a pair of FortiGates in two AZ's (in a new VPC)
provider "aws" { region = "${var.region}" }

module "fortigate-od" {
  source = "./fortigate-ondemand"

  region = "${var.region}"
}
module "vpc_setup" {
  source = "./VPC-Setup"

  region = "${var.region}"
  vpc_cidr = "${var.vpc_cidr}"
  public_subnet1 = "${var.public_subnet1}"
  public_subnet2 = "${var.public_subnet2}"
  private_subnet1 = "${var.private_subnet1}"
  private_subnet2 = "${var.private_subnet2}"
  stack_name = "${var.stack_name}"
}

# FortiGate 1 (AZ-1) ENIs:
resource "aws_network_interface" "fgt_1_pub" {
  subnet_id = "${module.vpc_setup.public_subnet1}"
  tags {
    Name = "FortiGate1-PubInt"
  }
}

resource "aws_network_interface" "fgt_1_priv" {
  subnet_id = "${module.vpc_setup.private_subnet1}"
  source_dest_check = "false"
  tags {
    Name = "FortiGate1-PrivInt"
  }
}

# FortiGate 1 (AZ-1) EC2:
resource "aws_instance" "fgt_1a" {
  ami = "${module.fortigate-od.ami_id}"
  instance_type = "${var.fgt_instance_size}"
  tags {
    Name = "FortiGate 1A"
  }
  network_interface {
    network_interface_id = "${aws_network_interface.fgt_1_pub.id}"
    device_index = 0
  }
  network_interface {
    network_interface_id = "${aws_network_interface.fgt_1_priv.id}"
    device_index = 1
  }
}

# FortiGate 2 (AZ-2) ENIs:
resource "aws_network_interface" "fgt_2_pub" {
  subnet_id = "${module.vpc_setup.public_subnet2}"
  tags {
    Name = "FortiGate2-PubInt"
  }
}

resource "aws_network_interface" "fgt_2_priv" {
  subnet_id = "${module.vpc_setup.private_subnet2}"
  source_dest_check = "false"
  tags {
    Name = "FortiGate2-PrivInt"
  }
}

# FortiGate 2 (AZ-2) EC2:
resource "aws_instance" "fgt_2b" {
  ami = "${module.fortigate-od.ami_id}"
  instance_type = "${var.fgt_instance_size}"
  tags {
    Name = "FortiGate 2B"
  }
  network_interface {
    network_interface_id = "${aws_network_interface.fgt_2_pub.id}"
    device_index = 0
  }
  network_interface {
    network_interface_id = "${aws_network_interface.fgt_2_priv.id}"
    device_index = 1
  }
}

# Internal Subnet Route Tables
resource "aws_route_table" "primary_private" {
  vpc_id = "${module.vpc_setup.vpc}"

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = "${aws_network_interface.fgt_1_priv.id}"
  }

  tags {
    Name = "Primary RT"
  }
}
resource "aws_route_table" "secondary_private" {
  vpc_id = "${module.vpc_setup.vpc}"

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = "${aws_network_interface.fgt_2_priv.id}"
  }

  tags {
    Name = "Secondary RT"
  }
}

# SNS Topic for Cloudwatch + Lambda integration
resource "aws_sns_topic" "fgt_healthcheck" {
  name = "fgt-health"
}

module "ha_by_routetables" {
  source = "./rt-ha"

  region = "${var.region}"
  sns_arn = "${aws_sns_topic.fgt_healthcheck.arn}"
  subnet1 = "${aws_route_table.primary_private.id}"
  subnet2 = "${aws_route_table.secondary_private.id}"

}

# Cloudwatch alarms for the two FGT instances:
resource "aws_cloudwatch_metric_alarm" "fgt1_monitor" {
  alarm_name = "fgt1_monitor"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "StatusCheckFailed"
  dimensions {
    InstanceId = "${aws_instance.fgt_1a.id}"
  }
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "1"
  alarm_description = "Monitors the health of FGT1 EC2 Instance"
  alarm_actions = ["${aws_sns_topic.fgt_healthcheck.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "fgt2_monitor" {
  alarm_name = "fgt2_monitor"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "StatusCheckFailed"
  dimensions {
    InstanceId = "${aws_instance.fgt_2b.id}"
  }
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Maximum"
  threshold = "1"
  alarm_description = "Monitors the health of FGT1 EC2 Instance"
  alarm_actions = ["${aws_sns_topic.fgt_healthcheck.arn}"]
}
