terraform {
  source = "github.com/insight-infrastructure/terraform-aws-packer-ami.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  packer = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer")}"
}

inputs = {
  name = "vault"
  distro = "ubuntu-18"
  node = "vault"

  packer_config_path = "${local.packer}/remote/ubuntu-18/vault.json"
  packer_vars = {}
}

