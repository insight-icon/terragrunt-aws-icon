terraform {
  source = "github.com/insight-infrastructure/terraform-aws-ec2-basic.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  name = local.group_vars["group"]

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("security-groups")}/sg-monitoring"
  user_data = "../user-data"
}

dependencies {
  paths = [local.vpc, local.sg, local.user_data]
}

dependency "vpc" {
  config_path = local.vpc
}

dependency "sg" {
  config_path = local.sg
}

dependency "user_data" {
  config_path = local.user_data
}

inputs = {
  name = local.name

  monitoring = true

  ebs_volume_size = 300
  root_volume_size = 25

  instance_type = "m5.large"
  volume_path = "/dev/xvdf"

  create_eip = true
  subnet_id = dependency.vpc.outputs.public_subnets[0]
  user_data = dependency.user_data.outputs.user_data
//  ami_id = dependency.ami.outputs.ami_id
  local_public_key = local.secrets["local_public_key"]
  vpc_security_group_ids = [dependency.sg.outputs.this_security_group_id]

  tags = {
    Network = "MainNet"
  }
}
