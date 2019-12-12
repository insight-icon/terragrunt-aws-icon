terraform {
  source = "."
}

include {
  path = find_in_parent_folders()
}

locals {
  secrets = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("secrets.yaml")}"))
}

dependencies {
  paths = [local.sg]
}

dependency "s3" {
  config_path = "../keys-bucket"
}

inputs = {
  key_name = basename(local.secrets["local_public_key"])

  bucket = dependency.s3.outputs.this_s3_bucket_id
  public_key = local.secrets["local_public_key"]
}
