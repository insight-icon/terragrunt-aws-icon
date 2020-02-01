terraform {
  source = "${local.source}"
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_owner = "insight-infrastructure"
  repo_name = "terraform-aws-icon-node-dns"
  repo_version = "master"
  repo_path = ""

  local_source = false
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
}

dependencies {
  paths = ["../eip", "../ec2"]
}

dependency "eip" {
  config_path = "../eip"
}

dependency "ec2" {
  config_path = "../ec2"
}

inputs = {
  hostname = "bastion"

  domain_name = local.domain_name
  internal_domain_name = local.private_tld

  public_ip = dependency.ec2.outputs.public_ip
  private_ip = dependency.ec2.outputs.private_ip

  tags = {}
}