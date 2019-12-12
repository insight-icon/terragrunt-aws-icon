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

  local_source = false
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  global_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))

  # Dependencies
  ec2 = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ec2")}"
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
}


dependencies {
  paths = [local.ec2, local.eip]
}

dependency "ec2" {
  config_path = local.ec2
}

dependency "eip" {
  config_path = local.eip
}

inputs = {
  ip = dependency.ec2.outputs.public_ip

  private_key_path = local.secrets["local_private_key"]

  user = "ubuntu"

  playbook_file_path = "${get_parent_terragrunt_dir()}/ansible/prep-block42.yml"
  roles_dir = "${get_parent_terragrunt_dir()}/ansible/roles"

  playbook_vars = {
    "public_ip": dependency.eip.outputs.public_ip
    "keystore_path" : local.secrets["keystore_path"]
    "keystore_password": local.secrets["keystore_password"]
    "network_name": local.global_vars["network_name"]
//    "image": local.group_vars["image_id"]
    "main_ip": dependency.eip.outputs.public_ip
  }
}
