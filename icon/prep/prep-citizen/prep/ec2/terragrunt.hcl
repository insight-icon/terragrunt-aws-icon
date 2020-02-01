terraform {
  source = "${local.source}"
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_owner = "insight-infrastructure"
  repo_name = "terraform-aws-ec2-basic"
  repo_version = "master"
  repo_path = ""

  local_source = false
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  name = local.group_vars["group"]

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("sg-prep")}"
  ami = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer-ami")}"
  user_data = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("user-data")}"
}

dependencies {
  paths = [local.vpc, local.sg, local.ami, local.user_data]
}

dependency "vpc" {
  config_path = local.vpc
}

dependency "sg" {
  config_path = local.sg
}

dependency "ami" {
  config_path = local.ami
}

dependency "user_data" {
  config_path = local.user_data
}

inputs = {
  name = local.name

  monitoring = true

  ebs_volume_size = 300
  root_volume_size = 25

  instance_type = "m5.xlarge"
  volume_path = "/dev/xvdf"

  subnet_id = dependency.vpc.outputs.public_subnets[0]
  user_data = dependency.user_data.outputs.user_data
  ami_id = dependency.ami.outputs.ami_id
  local_public_key = local.secrets["local_public_key"]
  security_groups = [dependency.sg.outputs.this_security_group_id]

  tags = {
    Network = "MainNet"
  }
}
