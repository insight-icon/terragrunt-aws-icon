terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v2.15.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  global_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("globals.yaml")}"))
}

inputs = {
  name = "icon-prep"

  enable_nat_gateway = false
  single_nat_gateway = false
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support = true

  azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

  cidr = "10.0.0.0/16"

  private_subnets = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  public_subnets = ["10.0.192.0/24", "10.0.193.0/24", "10.0.194.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
    NetworkName = local.global_vars["network_name"]
    Blockchain = "icon"
  }
}

