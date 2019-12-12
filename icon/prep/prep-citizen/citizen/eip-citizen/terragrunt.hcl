terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  # Dependencies
  ec2 = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ec2")}"
}

dependencies {
  paths = [local.ec2]
}

dependency "eip" {
  config_path = local.ec2
}

inputs = {
  name = "main"

  instance_id = dependency.ec2.outputs.instance_id
}

