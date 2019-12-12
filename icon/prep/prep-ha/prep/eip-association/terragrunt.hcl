terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  # Dependencies
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
  ec2 = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ec2-a")}"
  ansible_conf = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible-conf")}"
}

dependencies {
  paths = [local.ansible_conf]
}

dependency "eip" {
  config_path = local.eip
}

dependency "ec2" {
  config_path = local.ec2
}

inputs = {
  name = "main"

  instance_id = dependency.ec2.outputs.instance_id
  eip_id = dependency.eip.outputs.eip_id
}
