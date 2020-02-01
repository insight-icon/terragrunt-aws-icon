terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  label = "${get_parent_terragrunt_dir()}/${path_relative_to_include()}/${find_in_parent_folders("label")}"
}

dependencies {
  paths = [local.label]
}

dependency "label" {
  config_path = local.label
}

inputs = {
  tags = dependency.label.outputs.tags
}

