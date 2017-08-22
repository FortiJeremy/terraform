/*

This is a terraform to deploy 1 VPC, with two FortiGates functioning as NAT
gateways. Prereq's:
-Terraform installed (can be gotten at http://www.terraform.io/downlaods.html)

To deploy, download the git, enter the desired network configurations in the 
variables.tf file of this main directory, and then from the command line of 
the working folder of the git type:
terraform init
terraform get
terraform plan

After planning, review what resources will be created, and if its satisfactoy
enter:
terraform apply

This will deploy all the appropriate resources. */