terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  global_vars = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("global.yaml")}"))
}

inputs = {
  namespace = local.global_vars["namespace"]
  environment = local.global_vars["environment"]
  network_name = local.global_vars["network_name"]
  owner = local.global_vars["owner"]
  vpc_type = "main"
}
