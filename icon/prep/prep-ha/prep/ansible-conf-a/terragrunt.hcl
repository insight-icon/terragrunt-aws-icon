terraform {
  source = "${local.source}"
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_owner = "insight-infrastructure"
  repo_name = "terraform-aws-icon-node-configuration"
  repo_version = "master"
  repo_path = ""

  local_source = true
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  global_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))

  packer_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer")}"
  ansible_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"

  # Dependencies
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
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

  private_key_path = local.secrets["local_private_key"]

  user = "ubuntu"

  playbook_file_path = "${local.ansible_path}/prep-ha.yml"
  roles_dir = "${local.ansible_path}/roles"

  playbook_vars = {
    "keystore_path" : local.secrets["keystore_path"]
    "keystore_password": local.secrets["keystore_password"]
    "network_name": local.global_vars["network_name"]
    "image": local.group_vars["image_id"]
    "hostname" : "az-a-hb"
    "peer_hostname" : "az-b-hb"
    "peer_private_ip": dependency.ec2_b.outputs.private_ip
    "private_ip": dependency.ec2_a.outputs.private_ip
  }
}
