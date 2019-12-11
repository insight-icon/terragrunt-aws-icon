terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  eip = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("eip")}"
}

dependencies {
  paths = [local.eip]
}

dependency "eip" {
  config_path = local.eip
}

inputs = {
  organization_name = ""
  organization_country = ""
  organization_email = ""
  organization_city = ""
  organization_website = ""

  // ------------------Details

  logo_256 = ""
  logo_1024 = ""
  logo_svg = ""
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
  p2p_ip = ""
  keystore_path = ""
  keystore_password = ""


  region = "{{ cookiecutter.region }}"


}
