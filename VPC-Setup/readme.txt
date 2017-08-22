/* ./vpc/readme.txt Last Modified 2017-08-17

This module is used to create a VPC with 2 internal subnets, 2 external subnets, an 
internet gateway, and 2 route tables. 

The external subnets are publicly accessable, while the two internal are private. After 
creation, a NAT gateway (FortiGate) should be deployed with a NIC in each subnet (per 
availability zone), and the route tables for the private subnets should be adjusted to 
accomodate

Inputs:
The following variable can be passed to this module:
region 			- specifies the region to deploy in
vpc_cidr 		- The CIDR for the entire VPC
public_subnet1 	- Public Subnet for Availability Zone [0]
public_subnet2 	- Public Subnet for Availability Zone [1]
private_subnet1 - Private Subnet for Availability Zone [0]
private_subnet2 - Private Subnet for Availability Zone [1]
stack_name 		- Used as global tag to track fortinet/terraform deployed resources 
				  via console, key is literal

Outputs:
The following outputs are configured by default:
vpc 			- specifies the VPC ID of the created VPC
pubrt			- specifies the Public Route Table ID

*/