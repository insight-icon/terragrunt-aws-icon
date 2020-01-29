terraform {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  global_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))

  packer_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer")}"
  ansible_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"

  # Dependencies
  ec2_a = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ec2-a")}"
  ec2_b = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ec2-b")}"
}

dependencies {
  paths = [local.eip]
}

dependency "ip" {
  config_path = local.eip
}

dependency "ec2_a" {
  config_path = local.ec2_a
}

dependency "ec2_b" {
  config_path = local.ec2_b
}

inputs = {
  ip = dependency.ip.outputs.public_ip

  inventory = {

  }

  private_key_path = local.secrets["local_private_key"]

  user = "ubuntu"

  playbook_file_path = "${local.ansible_path}/prep-ha.yml"
  roles_dir = "${local.ansible_path}/roles"

// This needs to be filled in
  playbook_vars = {
    "keystore_path" : local.secrets["keystore_path"]
    "keystore_password": local.secrets["keystore_password"]
    "network_name": local.global_vars["network_name"]
    "hostname" : "az-a-hb"
    "peer_hostname" : "az-b-hb"
    "peer_private_ip": dependency.ec2_b.outputs.private_ip
    "private_ip": dependency.ec2_a.outputs.private_ip
    "slave_public_ip": dependency.ec2_b.outputs.public_ip
  }
}
