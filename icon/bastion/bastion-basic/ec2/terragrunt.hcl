terraform {
  source = "${local.source}"
}

include {
  path = find_in_parent_folders()
}

locals {
  repo_owner = "insight-infrastructure"
  repo_name = "terraform-aws-ec2-basic"
  repo_version = "master"
  repo_path = ""

  local_source = false
  modules_path = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("modules")}"

  source = local.local_source ? "${local.modules_path}/${local.repo_name}" : "github.com/${local.repo_owner}/${local.repo_name}.git//${local.repo_path}?ref=${local.repo_version}"

  group_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("group.yaml")}"))
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  name = local.group_vars["group"]

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("sg")}"
  user_data = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("user_data")}"
}

dependencies {
  paths = [local.vpc, local.sg, local.user_data]
}

dependency "vpc" {
  config_path = local.vpc
}

dependency "sg" {
  config_path = local.sg
}

dependency "user_data" {
  config_path = local.user_data
}

inputs = {
  name = local.name

  ebs_volume_size = 0
  root_volume_size = 8

  instance_type = "t2.micro"
  volume_path = "/dev/sdf"

  local_public_key = local.secrets["local_public_key"]

  user_data = dependency.user_data.outputs.user_data

  vpc_security_group_ids = [dependency.sg.outputs.this_security_group_id]
  subnet_id = dependency.vpc.outputs.public_subnets[0]

  json_policy_name = "S3KeysBucketRead"
  json_policy = <<-EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${bucket}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${dependency}/*"
    }
  ]
}
EOT

  tags = {}
}