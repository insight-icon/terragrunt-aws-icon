terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.1.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  coporate_ip = local.secrets["corporate_ip"]

  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  name = local.group_vars["group"]

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

  description = "Security group for bastion only allowing ssh access from coporate ip"
  vpc_id = dependency.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      description = "SSH ingress access from coporate ip only"
      cidr_blocks = "${local.coporate_ip}/32"
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port = 0
      to_port = 65535
      protocol = -1
      description = "Egress access open to all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  // Tags will be filled in later as appropriate
  tags = {}
}
