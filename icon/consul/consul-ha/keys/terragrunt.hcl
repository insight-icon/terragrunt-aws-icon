terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
}

inputs = {
  name = "consul"
  local_public_key = local.secrets["local_public_key"]
}
