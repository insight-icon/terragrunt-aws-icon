terraform {
  source = "github.com/insight-infrastructure/terraform-aws-ec2-basic.git?ref=master"
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))

  name = "hids-ec2"

  # Dependencies
  vpc = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("vpc")}"
  sg = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("security-groups")}/sg-hids"
  label = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("label")}"
  user_data = "../user-data"
  bucket = "../bucket"
}

dependencies {
  paths = [local.vpc, local.sg, local.label, local.user_data, local.bucket]
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

dependency "label" {
  config_path = local.label
}

dependency "bucket" {
  config_path = local.bucket
}


inputs = {
  name = local.name

  monitoring = true

  ebs_volume_size = 20
  root_volume_size = 14

  instance_type = "m5.large"
  volume_path = "/dev/xvdf"

  json_policy_name = "S3ReadVpcFlowLogsBucket"
  json_policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::wazuh-bucket-tmp",
                "arn:aws:s3:::wazuh-bucket-tmp/*"
            ]
        }
    ]
}
EOF

  create_eip = true
  subnet_id = dependency.vpc.outputs.public_subnets[0]
  user_data = dependency.user_data.outputs.user_data

  local_public_key = local.secrets["local_public_key"]
  vpc_security_group_ids = [dependency.sg.outputs.this_security_group_id]

  tags = dependency.label.outputs.tags
}
