terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group.git?ref=v3.2.0"
}

include {
  path = find_in_parent_folders()
}

locals {
  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))

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
  description = "Security group for elasticsearch"
  vpc_id = dependency.vpc.outputs.vpc_id

//  TODO: Fix this
  ingress_cidr_blocks = "0.0.0.0/0"
  ingress_rules = [
    "https-443-tcp"]

  tags = {}
}