## Mappings for FortiGate-OnDemand
variable "region" {}

variable "ami_id" {
  type = "map"

  default = {
    us-east-1      = "ami-97f7d480"
    us-east-2      = "ami-88570ded"
    eu-west-1      = "ami-1ac79069"
    eu-west-2      = "ami-462d2722"
    eu-central-1   = "ami-22a75d4d"
    ap-northeast-1 = "ami-a2b917c3"
    ap-northeast-2 = "ami-a84296c6"
    ap-southeast-1 = "ami-24359547"
    ap-southeast-2 = "ami-686b540b"
    ap-south-1     = "ami-6c9aee03"
    sa-east-1      = "ami-15f56a79"
    us-west-1      = "ami-3be8a25b"
    us-west-2      = "ami-113b9b71"
    ca-central-1   = "ami-689a380d"
  }
}

output "ami_id" {
  value = "${lookup(var.ami_id, var.region)}"
}
