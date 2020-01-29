terraform {
  source = "github.com/insight-infrastructure/terraform-aws-packer-ami.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  # Dependencies
  packer_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer")}"
  ansible_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
}


inputs = {
  node = "prep"
  distro = "ubuntu-18"

  packer_config_path = "${local.packer_path}/remote/ubuntu-18/prep.json"

  packer_vars = {
    playbook_file_path = "${local.ansible_path}/packer-prep.yml"
  }

  tags = {}
}