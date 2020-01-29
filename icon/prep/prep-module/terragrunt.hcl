terraform {
  source = "github.com/insight-infrastructure/terraform-aws-icon-prep-basic.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  global = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  nodes = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("nodes.yaml")}"))

  # Dependencies
  ansible = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"

  name = "prep-module"
}

dependencies {
  paths = [local.eip]
}

dependency "eip" {
  config_path = local.eip
}

// ######################
// Deploys to Default VPC
// ######################

inputs = {
  name = local.name

  monitoring = true

  network_name = local.global.network_name
  eip_id = dependency.eip.outputs.eip_id
  main_ip = dependency.eip.outputs.public_ip

//  ebs_volume_size = 150
//  root_volume_size = 50
//  instance_type = "t3.medium"

  instance_type = local.nodes["${local.name}"].instance_type
  ebs_volume_size = local.nodes["${local.name}"].ebs_volume_size
  root_volume_size = local.nodes["${local.name}"].root_volume_size

  volume_path = "/dev/xvdf"

  public_key_path = local.secrets["local_public_key"]
  private_key_path = local.secrets["local_private_key"]

  keystore_path = local.secrets["keystore_path"]
  keystore_password = local.secrets["keystore_password"]

  playbook_file_path = "${local.ansible}/prep-basic.yml"
  roles_dir = "${local.ansible}/roles"

  tags = {}
}
