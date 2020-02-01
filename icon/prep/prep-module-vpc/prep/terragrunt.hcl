terraform {
  source = "github.com/insight-infrastructure/terraform-aws-icon-prep-basic.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  global = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))
  nodes = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("nodes.yaml")}"))

  # Dependencies
  ansible = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
  data = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("data")}"

  name = "prep-module-vpc"
}

dependencies {
  paths = [local.data]
}

dependency "data" {
  config_path = local.data
}

inputs = {
  name = "prep-module"
  tags = dependency.data.outputs.tags

  monitoring = true

  network_name = local.global.network_name

  subnet_id = dependency.data.outputs.public_subnets[0]
  vpc_security_group_ids = dependency.data.outputs.vpc_security_group_ids

  eip_id = dependency.data.outputs.eip_id
  main_ip = dependency.data.outputs.public_ip

//  ebs_volume_size = 150
//  root_volume_size = 25
//  instance_type = "t3.large"

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
  playbook_vars = local.nodes["${local.name}"]["additional_playbook_vars"]
}
