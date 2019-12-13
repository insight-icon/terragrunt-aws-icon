terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.2.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  name = "prep"
  description = "All traffic"

  corporate_ip = local.secrets["corporate_ip"]
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
}

dependencies {
  paths = [local.vpc]
}

dependency "vpc" {
  config_path = local.vpc
}

inputs = {
  name = local.name

  description = local.description
  vpc_id = dependency.vpc.outputs.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port = 0
      to_port = 65535
      protocol = -1
      description = "Egress access open to all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      description = "Security group for ssh access from coporate ip"
      cidr_blocks = local.corporate_ip == "" ? "0.0.0.0/0" : "${local.corporate_ip}/32"
    },
    {
      from_port = 9000
      to_port = 9000
      protocol = "tcp"
      description = "Security group json rpc traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {}
}
