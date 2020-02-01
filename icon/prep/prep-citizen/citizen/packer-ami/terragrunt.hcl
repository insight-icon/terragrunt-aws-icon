terraform {
  source = "${local.source}"
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_owner = "insight-infrastructure"
  repo_name = "terraform-aws-packer-ami"
  repo_version = "master"
  repo_path = ""

  local_source = true
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  # Dependencies
  packer_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer")}"
  ansible_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
}


inputs = {
  node = "prep"
  distro = "ubuntu-18"

  packer_config_path = "${local.packer_path}/packer/remote/ubuntu-18/prep.json"

  packer_vars = {
    playbook_file_path = "${local.ansible_path}/ansible/packer-citizen.yml"
  }

  tags = {}
}