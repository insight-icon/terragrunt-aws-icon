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

  ansible_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"

  # Dependencies
  ec2 = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ec2-b")}"
}

dependencies {
  paths = [local.ec2]
}

dependency "ip" {
  config_path = local.ec2
}

inputs = {
  ip = dependency.eip.outputs.public_ip

  private_key_path = local.secrets["local_private_key"]

  user = "ubuntu"

  playbook_file_path = "${local.ansible_path}/prep-ha.yml"
  roles_dir = "${local.ansible_path}/roles"

  playbook_vars = {
    "keystore_path" : local.secrets["keystore_path"]
    "keystore_password": local.secrets["keystore_password"]
    "network_name": local.global_vars["network_name"]
  }
}
