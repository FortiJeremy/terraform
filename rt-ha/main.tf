# ./rt-ha/main.tf   Last modified 2017-08-19
# This module is to insert the A-P route table swapping 
# High Availability scripts into lambda

variable "region" {}
variable "sns_arn" {}
variable "subnet1" {}
variable "subnet2" {}

provider "aws" { region = "${var.region}" }

# Installs the role needed for the lambda invocation
resource "aws_iam_role" "ftnt_lambda_role" {
    name = "ftnt_lambda_role"

    assume_role_policy = <<E0F
{
    "Version": "2012-10-17", 
        "Statement": [
            {
                "Action": "sts:AssumeRole", 
                "Effect": "Allow", 
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                }
            }
        ]
}
  E0F
}

resource "aws_iam_role_policy_attachment" "attach1" {
    role = "${aws_iam_role.ftnt_lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "attach2" {
    role = "${aws_iam_role.ftnt_lambda_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

# Lambda
resource "aws_lambda_function" "rt_mover" {
    filename = "./rt_mover.zip"
    function_name = "ftnt_rt_flip"
    role = "${aws_iam_role.ftnt_lambda_role.arn}"
    handler = "route-tables.do"
    runtime = "python2.7"
    source_code_hash = "${base64sha256(file("./rt_mover.zip"))}"

    environment {
        variables {
            route_table_1 = "${var.subnet1}"
            route_table_2 = "${var.subnet2}"
            ha_region = "${var.region}"
        }
    }

}

output "lambda_arn" {
    value = "${aws_lambda_function.rt_mover.arn}"
}