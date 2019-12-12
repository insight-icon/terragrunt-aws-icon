terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.2.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  corporate_ip = local.secrets["corporate_ip"]
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  global_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))

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
  name = local.group_vars["group"]

  description = "P-Rep SG"

  vpc_id = dependency.vpc.outputs.vpc_id

  egress_with_cidr_blocks = [{
    from_port = 0
    to_port = 65535
    protocol = -1
    description = "Egress access open to all"
    cidr_blocks = "0.0.0.0/0"
  },]

  ingress_with_cidr_blocks = [{
    from_port = 7100
    to_port = 7100
    protocol = "tcp"
    description = "grpc traffic for when node starts producing blocks"
    cidr_blocks = "0.0.0.0/0"
  }, {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    description = "Security group json rpc traffic"
    cidr_blocks = "0.0.0.0/0"
  },
  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    description = "Security group for ssh access from coporate ip"
    cidr_blocks = local.secrets["corporate_ip"] == "" ? "0.0.0.0/0" : "${local.secrets["corporate_ip"]}/32"
  }]

  tags = {}
}
