//terraform {
//  source = "github.com/insight-infrastructure/terraform-aws-icon-node-dns.git?ref=master"
//}
//
//include {
//  path = find_in_parent_folders()
//}
//
//locals {
//  ec2 = "../ec20"
//  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
//}
//
//dependencies {
//  paths = [local.ec2]
//}
//
//dependency "ec2" {
//  config_path = local.ec2
//}
//
//inputs = {
//  hostname = "monitoring"
//
//  domain_name = local.secrets["domain_name"]
//  internal_domain_name = local.secrets["private_tld"]
//
//  public_ip = dependency.ec2.outputs.public_ip
//  private_ip = dependency.ec2.outputs.private_ip
//}