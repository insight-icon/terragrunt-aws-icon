terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
  label = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("label")}"
}

dependencies {
  paths = [local.label]
}

dependency "label" {
  config_path = local.label
}

inputs = {
// Path needs to be filled in otherwise registration doesn't work
//  keystore_path = ""
  keystore_path = local.secrets["keystore_path"]

// If you leave these commented out, you will be prompted for password each time
//  keystore_password = ""
  keystore_password = local.secrets["keystore_password"]

// If you have already registered an IP, you can fill this in and a new IP will not be provisioned
  ip = "1.2.3.4"

// This MUST be set right from the get go. Options are `mainnet` or `testnet`
//  If you do this wrong for main, you will have to switch wallet most likely (untested)
  network_name = "testnet"

  // These five values are mandatory
  organization_name = "Insight-C2"
  organization_country = "USA"
  organization_email = "insight.icon.prep@gmail.com"
  organization_city = "San Francisco"
  organization_website = "insight-icon.net"

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

  server_type = ""
  region = ""
  region = ""

//  Do not change this
  tags = dependency.label.outputs.tags
}
