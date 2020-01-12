terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  global = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))
  label = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("label")}"
}

dependencies {
  paths = [local.label]
}

dependency "label" {
  config_path = local.label
}

inputs = {
  // These five values are mandatory.  Fill them out per your teams information
  organization_name = "Insight-C10"
  organization_country = "USA"
  organization_email = "insight.icon.prep@gmail.com"
  organization_city = "San Francisco"
  organization_website = "https://insight-icon.net"

// Path needs to be filled in otherwise registration doesn't work
//  keystore_path = ""
  keystore_path = local.secrets["keystore_path"]

// If you leave these commented out, you will be prompted for password each time
//  keystore_password = ""
  keystore_password = local.secrets["keystore_password"]

// If you have already have an IP, you can enter it here / uncomment and a new IP will not be provisioned with the
// existing IP being brought
//  ip = "1.2.3.4"

// This MUST be set right from the get go. Options are `mainnet` or `testnet`
// Fill it out in global.yaml at root
  network_name = local.global["network_name"]

  // ------------------Details

// All the logos are complete paths to the image on your local drive
  logo_256 = ""
  logo_1024 = ""
  logo_svg = ""

// All of this is optional
  steamit = ""
  twitter = ""
  youtube = ""
  facebook = ""
  github = ""
  reddit = ""
  keybase = ""
  telegram = ""

  server_type = "cloud"
  region = "us-east-2"

//  Do not change this
  tags = dependency.label.outputs.tags
}
