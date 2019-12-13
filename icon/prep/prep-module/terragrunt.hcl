terraform {
  source = "github.com/insight-infrastructure/terraform-aws-icon-prep-basic.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  # Dependencies
  ansible = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
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
  name = "prep-module"

  monitoring = true

  network_name = "testnet"
  eip_id = dependency.eip.outputs.eip_id
  main_ip = dependency.eip.outputs.public_ip

  ebs_volume_size = 150
  root_volume_size = 25

  instance_type = "m5.large"
  volume_path = "/dev/xvdf"

  public_key_path = local.secrets["local_public_key"]
  private_key_path = local.secrets["local_private_key"]

  keystore_path = local.secrets["keystore_path"]
  keystore_password = local.secrets["keystore_password"]

  playbook_file_path = "${local.ansible}/prep-basic.yml"
  roles_dir = "${local.ansible}/roles"

  tags = {}
}
