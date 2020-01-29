terraform {
  source = "github.com/hashicorp/terraform-aws-vault//modules/vault-cluster"
}
include {
  path = find_in_parent_folders()
}

locals {
  # Dependencies
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("security-groups")}/sg-vault"
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
}

dependencies {
  paths = [local.sg, "../packer-ami", "../keys", local.vpc]
}

dependency "sg" {
  config_path = local.sg
}

dependency "keys" {
  config_path = "../keys"
}

dependency "packer_ami" {
  config_path = "../packer-ami"
}

dependency "vpc" {
  config_path = local.vpc
}

inputs = {
  name = "vault"

  cluster_name = "vault-servers"
  ami_id = dependency.packer_ami.outputs.ami_id

  instance_type = "t2.micro"
  vpc_id = dependency.vpc.outputs.vpc_id

  additional_security_group_ids = [dependency.sg.outputs.this_security_group_id]

// TODO: Check if we can eliminate this to only have access from within security groups, not cidr blocks
  allowed_inbound_cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12"]

  allowed_inbound_ssh_security_group_ids = local.global["bastion_enabled"] ? [dependency.bastion_sg.outputs.this_security_group_id] : []

  user_data = <<-EOF
              #!/bin/bash
              /opt/vault/bin/run-vault --tls-cert-file /opt/vault/tls/vault.crt.pem --tls-key-file /opt/vault/tls/vault.key.pem
              EOF

  cluster_size = 3

  availability_zones = dependency.vpc.outputs.azs
  subnet_ids = dependency.vpc.outputs.public_subnets
  ssh_key_name = dependency.keys.outputs.key_name
}