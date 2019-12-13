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

  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  # Dependencies
  ansible = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
  eip_association = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip-association")}"
}

dependencies {
  paths = [local.eip_association, local.eip]
}

dependency "eip" {
  config_path = local.eip
}

inputs = {
  ip = dependency.eip.outputs.public_ip

  private_key_path = local.secrets["local_private_key"]
  user = "ubuntu"

  playbook_file_path = "${local.ansible}/prep-start.yml"
  roles_dir = "${local.ansible}/roles"

  playbook_vars = {}
}
