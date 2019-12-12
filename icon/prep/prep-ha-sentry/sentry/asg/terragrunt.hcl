terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-autoscaling.git"
}

include {
  path = find_in_parent_folders()
}

locals {
  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  name = local.group_vars["group"]

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("sg")}/security-groups/sg-prep"
  packer_ami = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("packer-ami")}"
  user_data = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("user-data")}"
}

dependencies {
  paths = [local.vpc, local.packer_ami, local.user_data]
}

dependency "vpc" {
  config_path = local.vpc
}

dependency "sg" {
  config_path = local.sg
}

dependency "packer_ami" {
  config_path = local.packer_ami
}

dependency "user_data" {
  config_path = local.user_data
}


inputs = {
  name = "sentry"
  spot_price = "1"

  user_data = dependency.user_data.outputs.user_data

  key_name = "prep"

  # Launch configuration
  lc_name = "prep-sentry-lc"

  image_id = dependency.packer_ami.outputs.ami_id
  instance_type = "c4.large"
  security_groups = [dependency.sg.outputs.this_security_group_id]

  //TODO: Trim this
  root_block_device = [{
    volume_size = "8"
    volume_type = "gp2"
  }]

  # Auto scaling group
  asg_name = "p-rep-sentry-asg"

  vpc_zone_identifier = dependency.vpc.outputs.private_subnets

  health_check_type = "EC2"
  //  TODO Verify ^^
  min_size = 1
  max_size = 3
  desired_capacity = 1
  wait_for_capacity_timeout = 0

  tags = [{
    key = "Environment"
    value = "prod"
    propagate_at_launch = true
  }]
}
