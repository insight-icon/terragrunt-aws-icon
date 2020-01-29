terraform {
  source = "github.com/insight-infrastructure/terraform-aws-ansible-playbook.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  # Dependencies
  ec2 = "../ec2"
  ansible = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("ansible")}"
}

dependencies {
  paths = [local.ec2]
}

dependency "ec2" {
  config_path = local.ec2
}

inputs = {
  ip = dependency.ec2.outputs.public_ip
  private_key_path = local.secrets["local_private_key"]
  user = "ubuntu"
  playbook_file_path = "${local.ansible}/hids-elasticsearch-ec2.yml"
  roles_dir = "${local.ansible}/roles"

  # This is what needs to be filled in to make this work
  playbook_vars = {}
}
