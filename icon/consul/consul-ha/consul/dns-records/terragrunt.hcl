terraform {
  source = "${local.source}"
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_owner = "insight-infrastructure"
  repo_name = "terraform-aws-icon-consul-dns"
  repo_version = "master"
  repo_path = ""

  local_source = false
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  # Dependencies
  dns = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("dns")}"
}

dependencies {
  paths = [local.dns, "../asg"]
}

dependency "dns" {
  config_path = local.dns
}

inputs = {
  zone_id = dependency.dns.outputs.private_zone_id
}
