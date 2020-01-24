terraform {
  source = "github.com/insight-infrastructure/terraform-aws-ec2.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  nodes = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("nodes.yaml")}"))

  name = local.group_vars["group"]

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("security-groups")}/sg-prep"
  packer = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer-ami")}"
  user_data = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("user-data")}"
}

dependencies {
  paths = [local.vpc, local.sg, local.packer, local.user_data]
}

dependency "vpc" {
  config_path = local.vpc
}

dependency "sg" {
  config_path = local.sg
}

dependency "packer" {
  config_path = local.packer
}

dependency "user_data" {
  config_path = local.user_data
}

inputs = {
  name = "${local.name}-b"

  monitoring = true

//  ebs_volume_size = 300
//  root_volume_size = 25
//  instance_type = "m5.xlarge"

  instance_type = local.nodes["${local.name}"].instance_type
  ebs_volume_size = local.nodes["${local.name}"].ebs_volume_size
  root_volume_size = local.nodes["${local.name}"].root_volume_size

  volume_path = "/dev/xvdf"

  subnet_id = dependency.vpc.outputs.public_subnets[1]

  ami_id = dependency.packer.outputs.ami_id

  user_data = dependency.user_data.outputs.user_data

  local_public_key = local.secrets["local_public_key"]

  vpc_security_group_ids = [dependency.sg.outputs.this_security_group_id]

  tags = {
    Network = "MainNet"
  }
}
