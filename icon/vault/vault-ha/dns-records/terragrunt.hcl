terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  global = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))
}

dependencies {
  paths = ["../asg"]
}

inputs = {
  private_tld = local.global["private_tld"]
}
